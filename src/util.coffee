PATTERN = 'GetReportBlock_'

Util =
    QAWS: "QAWS"
    WEBI: "WEBI"

    getType: (typeDesc) ->
        switch typeDesc
            when 's:double', 'xsd:double' then 'DOUBLE'
            when 's:string', 'xsd:string' then 'STRING'
            else 'STRING'

    methodToTable: (methodName) ->
        index = methodName.indexOf PATTERN
        if index is 0
            return methodName.substring PATTERN.length, methodName.length
        return null

    getServiceType: (wsdl) ->
        if wsdl?.definitions?.descriptions?.types?.Row?
            Util.QAWS
        else
            Util.WEBI

    getMethodName: (tableName) ->
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
