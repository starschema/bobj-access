soap =  require 'soap'
util = require './util'

callSoapMethod = (client, methodName, credentials, options, callback) ->
    options ?= {}
    options.login = credentials.username
    options.password = credentials.password
    client[methodName] [options], callback

extractFieldsFromWSDL = (client, credentials, callback) ->
    fields = []
    if util.getServiceType(client.wsdl) is util.QAWS
        for field, typeDesc of client.wsdl.definitions.descriptions.types.Row
            if field isnt 'targetNSAlias' and field isnt 'targetNamespace'
                fields.push {name: field, type: util.getType(typeDesc)}
        callback null, fields
    else
        callSoapMethod client, util.getMethodName(client.describe()), credentials, {startRow: 1, endRow: 1}, (err, results) ->
            unless err?
                for row in results.headers.row
                    for cell in row.cell
                        console.log "Pushing cell: ", cell.$value, cell.attributes
                        fields.push {name: cell.$value, type: util.getType(cell.attributes['xsi:type'])}
            callback err, fields

getTableName = (wsdlUrl, callback) ->
    soap.createClient wsdlUrl, (err, client) ->
        for tableName, tables of client.describe()
            callback err, tableName
            return
        callback new Error("Could not find table name in wsdl"), null

getFields = (wsdlUrl, credentials, callback) ->
    if not wsdlUrl?
        callback new Error("Invalid config. No WSDL set.")
        return
    soap.createClient wsdlUrl, (err, client) ->
        unless err?
            extractFieldsFromWSDL client, credentials, callback
        else
            callback err, null

getTables = (wsdl, credentials, callback) ->
    getTableName wsdl, (err, tableName) ->
        unless err?
            getFields wsdl, credentials, (err, fields) ->
                tables = [
                    Name: tableName
                    Fields: fields
                ]
                callback err, tables
        else
            callback err, null

getTableData = (wsdlUrl, credentials, callback) ->
    getFields wsdlUrl, credentials, (err, fields) ->
        unless err?
            soap.createClient wsdlUrl, (err, client) ->
                unless err?
                    callSoapMethod client, util.getMethodName(client.describe()), credentials, {}, (err, results) ->
                        unless err?
                            data = results.table.row
                            if util.getServiceType(client.wsdl) is util.QAWS
                                data = util.transformQAWSToObjectArray fields, data
                            else
                                data = util.transformWebIToObjectArray fields, data
                        callback err, data
                else
                    callback err, null
        else
            callback err, null

module.exports =
    getTables: getTables
    getTableData: getTableData
