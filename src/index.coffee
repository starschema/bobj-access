soap =  require 'soap'
util = require './util'
parseWebiTableXml = require './table_sax_parser'

callSoapMethod = (client, methodName, credentials, options, callback) ->
    options ?= {}
    options.login = credentials.username
    options.password = credentials.password
    client[methodName] [options], callback

extractFieldsFromWSDL = (client, credentials, tableName, callback) ->
    fields = []
    if util.getServiceType(client.wsdl) is util.QAWS
        for field, typeDesc of client.wsdl.definitions.descriptions.types.Row
            if field isnt 'targetNSAlias' and field isnt 'targetNamespace'
                fields.push {name: field, type: util.getType(typeDesc)}
        callback null, fields
    else
        callSoapMethod client, util.getMethodName(tableName), credentials, {startRow: 1, endRow: 1}, (err, results) ->
            if not results?.headers?.row?
                errorMessage = "Could not get records from soap."
                if results?.message?
                    errorMessage += results.message
                err = new Error errorMessage
            unless err?
                for row in results.headers.row
                    for index, cell of row.cell
                        data = results.table.row[0].cell[index]
                        fields.push {name: cell.$value, type: util.getType(data.attributes['xsi:type'])}
            callback err, fields

getTableList = (wsdlUrl, callback) ->
    soap.createClient wsdlUrl, (err, client) ->
        unless err?
            tables = []
            for reportName, reports of client.describe()
                for serviceType, method of reports
                    for methodName of method
                        tableName = util.methodToTable methodName
                        if tableName?
                            tables.push tableName
            callback err, tables
        else
            callback err, null

getTableName = (wsdlUrl, callback) ->
    soap.createClient wsdlUrl, (err, client) ->
        unless err?
            for tableName, tables of client.describe()
                callback err, tableName
                return
            callback new Error("Could not find table name in wsdl"), null
        else
            callback err, null

getFields = (wsdlUrl, credentials, tableName, callback) ->
    if not wsdlUrl?
        callback new Error("Invalid config. No WSDL set.")
        return
    soap.createClient wsdlUrl, (err, client) ->
        unless err?
            extractFieldsFromWSDL client, credentials, tableName, callback
        else
            callback err, null

getTableData = (wsdlUrl, credentials, tableName, options, callback) ->
    getFields wsdlUrl, credentials, tableName, (err, fields) ->
        unless err?
            soap.createClient wsdlUrl, (err, client) ->
                unless err?
                    soapOptions = {}
                    if options?.Limit? > 0
                        soapOptions.startRow = 1
                        soapOptions.endRow = options.Limit
                    callSoapMethod client, util.getMethodName(tableName, client), credentials, soapOptions, (err, results, raw) ->
                        unless err?
                            data = results.table.row
                            if util.getServiceType(client.wsdl) is util.QAWS
                                data = util.transformQAWSToObjectArray fields, data
                            else
                                data = parseWebiTableXml(raw)
                        callback err, data
                else
                    callback err, null
        else
            callback err, null


module.exports =
    getTableList: getTableList
    getFields: getFields
    getTableData: getTableData
