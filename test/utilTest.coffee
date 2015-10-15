util = require '../src/util'

chai = require 'chai'
should = chai.should()

describe 'getType', ->
    it 'should standardize different BO types', ->
        util.getType('s:double').should.equal util.getType('xsd:double')
        util.getType('s:string').should.equal util.getType('xsd:string')

describe 'getServiceType', ->
    it 'should give back either QAWS or WEBI', ->
        util.getServiceType(null).should.equal util.WEBI
        wsdl =
            definitions:
                descriptions:
                    types:
                        Row: {}
        util.getServiceType(wsdl).should.equal util.QAWS

describe 'getMethodName', ->
    it 'should give back empty string for malformed input', ->
        util.getMethodName(null).should.equal ''
        util.getMethodName({}).should.equal ''
        util.getMethodName([]).should.equal ''

    it 'should give back the name of the method for correct input', ->
        util.getMethodName('testMethod').should.equal 'GetReportBlock_testMethod'
        client = { wsdl: { definitions: { descriptions: { types: Row: {}}}}}
        util.getMethodName('testMethod', client).should.equal 'testMethod'

describe 'transformWebIToObjectArray', ->
    it 'should return empty array for malformed input', ->
        util.transformWebIToObjectArray(null, null).should.deep.equal []
        util.transformWebIToObjectArray(null, []).should.deep.equal []
        util.transformWebIToObjectArray(null, ['test']).should.deep.equal []

    it 'should transform well formed input', ->
        data = [
            cell: [
                $value: 'dataValue'
            ]
        ]
        fields = [
            name: 'fieldName'
        ]
        util.transformWebIToObjectArray(fields, data).should.deep.equal [{fieldName: 'dataValue'}]

describe 'transformQAWSToObjectArray', ->
    it 'should return empty array for malformed input', ->
        util.transformQAWSToObjectArray(null, null).should.deep.equal []
        util.transformQAWSToObjectArray(null, []).should.deep.equal []
        util.transformQAWSToObjectArray(null, ['test']).should.deep.equal []

    it 'should transform well formed input', ->
        data = [{fieldName: 'dataValue'}]
        fields = [
            name: 'fieldName'
        ]
        util.transformQAWSToObjectArray(fields, data).should.deep.equal [{fieldName: 'dataValue'}]

describe 'methodToTable', ->
    it 'should detect tables', ->
        util.methodToTable('GetReportBlock_virtdb-webi-test2').should.equal 'virtdb-webi-test2'
        util.methodToTable('GetReportBlock_bobj-access-demo').should.equal 'bobj-access-demo'
        util.methodToTable('runQueryAsAService').should.equal 'runQueryAsAService'

    it 'should return null for non-tables', ->
        should.not.exist util.methodToTable('Drill_bobj-access-demo')

