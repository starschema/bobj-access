PATTERN = 'GetReportBlock_'
ANTI_PATTERN = 'Drill_'

Util =
    QAWS: "QAWS"
    WEBI: "WEBI"

    getType: (typeDesc) ->
        switch typeDesc
            when 's:double', 'xsd:double' then 'DOUBLE'
            when 's:string', 'xsd:string' then 'STRING'
            when 's:dateTime', 'xsd:dateTime' then 'DATETIME'
            else 'STRING'

    methodToTable: (methodName) ->
        if (methodName.indexOf PATTERN) is 0
            return methodName.substring PATTERN.length, methodName.length
        else if (methodName.indexOf ANTI_PATTERN) is 0
            return null
        else
            return methodName

    getServiceType: (wsdl) ->
        if wsdl?.definitions?.descriptions?.types?.Row?
            Util.QAWS
        else
            Util.WEBI

    getMethodName: (tableName, client) ->
        if client?
            if Util.getServiceType(client.wsdl) is Util.QAWS
                return tableName
        if not tableName? or typeof(tableName) isnt 'string'
            return ''
        return PATTERN + tableName

    transformWebIToObjectArray: (fields, data) ->
        ret = []
        if data?.length? > 0
            ret =
                data.map (row) ->
                    item = null
                    if row?.cell?.length > 0
                        item = {}
                        for field,index in row.cell
                            item[fields[index].name] = field.$value
                    return item
                .filter (row) ->
                    row isnt null
        return ret

    transformQAWSToObjectArray: (fields, data) ->
        if not data? or not fields?
            return []
        data


module.exports = Util
