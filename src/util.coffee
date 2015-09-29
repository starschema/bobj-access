Util =
    QAWS: "QAWS"
    WEBI: "WEBI"

    getType: (typeDesc) ->
        switch typeDesc
            when 's:double', 'xsd:double' then 'DOUBLE'
            when 's:string', 'xsd:string' then 'STRING'
            else 'STRING'

    getServiceType: (wsdl) ->
        if wsdl?.definitions?.descriptions?.types?.Row?
            Util.QAWS
        else
            Util.WEBI

    getMethodName: (description) ->
        for tableName, tables of description
            for serviceType, method of tables
                for methodName of method
                    return methodName
        return ''

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
