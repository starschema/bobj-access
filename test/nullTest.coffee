util = require '../src/util'

chai = require 'chai'
should = chai.should()

parseWebiTableXml = require '../src/table_sax_parser'

describe 'parseWebiTableXml', ->
    it 'should handle null fields correctly', ->
      input = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><GetReportBlock_excelnullResponse xmlns="excelnull"><headers><row><cell xsi:type="xsd:string">A</cell><cell xsi:type="xsd:string">B</cell><cell xsi:type="xsd:string">C</cell><cell xsi:type="xsd:string">D</cell><cell xsi:type="xsd:string">E</cell></row></headers><table><row><cell xsi:type="xsd:double">1</cell><cell xsi:type="xsd:string">a</cell><cell xsi:type="xsd:double">5</cell><cell xsi:type="xsd:double">1</cell><cell xsi:type="xsd:string">aa</cell></row><row><cell xsi:type="xsd:double">2</cell><cell xsi:type="xsd:string">b</cell><cell xsi:type="xsd:double" xsi:nil="true" /><cell xsi:type="xsd:double">2</cell><cell xsi:type="xsd:string">bb</cell></row><row><cell xsi:type="xsd:double">3</cell><cell xsi:type="xsd:string">c</cell><cell xsi:type="xsd:double">1234</cell><cell xsi:type="xsd:double">3</cell><cell xsi:type="xsd:string">cc</cell></row></table><user>Administrator</user><documentation></documentation><documentname>WSNullTest</documentname><lastrefreshdate>2016-07-15T15:57:10.0</lastrefreshdate><creationdate>2016-07-15T15:58:44.988</creationdate><creator>Administrator</creator><isScheduled>false</isScheduled><tableType>Vertical Table</tableType><nbColumns>5</nbColumns><nbLines>3</nbLines></GetReportBlock_excelnullResponse></soap:Body></soap:Envelope>'
      parsed = parseWebiTableXml(input)

      parsed.data.should.deep.equal([
        { A: '1', B: 'a', C: '5', D: '1', E: 'aa' },
        { A: '2', B: 'b', C: null, D: '2', E: 'bb' },
        { A: '3', B: 'c', C: '1234', D: '3', E: 'cc' }
      ])

      parsed.fields.should.deep.equal([
        { name: 'A', type: 'xsd:double' },
        { name: 'B', type: 'xsd:string' },
        { name: 'C', type: 'xsd:double' },
        { name: 'D', type: 'xsd:double' },
        { name: 'E', type: 'xsd:string' }
      ])
