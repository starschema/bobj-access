sax = require("sax")


generateResultParser = (data)->

  # The state of the parser
  state = {}

  strict = true
  parser = sax.parser(strict)

  isInTable = false
  isInCell = true
  rows = []
  currentRow = []

  isInHeader = false
  headerFields = []

  parser.onerror = (e)-> console.error "ERROR:", e

  parser.ontext = (t)->
    headerFields.push(t) if isInHeader
    currentRow.push(t) if isInCell

  parser.onopentag = (node)->
    switch node.name
      when 'table' then isInTable = true
      when 'headers' then isInHeader = true
      when 'row' then currentRow = []

      when 'cell'
        break unless isInTable

        # handle nils here (not in ontext())
        # TODO: what if xsi refers to a different namespace?
        if node.attributes['xsi:nil']
          currentRow.push(null)
        else
          isInCell = true


  parser.onclosetag = (name)->
    switch name
      when 'table' then isInTable = false
      when 'headers' then isInHeader = false
      when 'row'
        break unless isInTable
        rows.push(currentRow)
        currentRow = []

      when 'cell'
        # exit from the cell state
        isInCell = false


  # Parse the xml
  parser.write(data).close()

  output = for row in rows
    o = {}
    for fieldName, fieldIdx in headerFields
      o[fieldName] = row[fieldIdx]
    o



  output

module.exports = generateResultParser
