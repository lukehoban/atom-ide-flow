fuzzaldrin = require 'fuzzaldrin'
{isFlowSource} = require './utils'
utilFlowCommand = require './util-flow-command'

module.exports =
  selector: '.source.js, .source.jsx'
  blacklist: '.source.js .comment'
  requestHandler: (options) ->
    editor = atom.workspace.getActiveEditor()
    return unless isFlowSource editor
    bufferPt = editor.getCursorBufferPosition()
    selection = editor.getSelection()
    prefix = options.prefix
    results = utilFlowCommand.autocompleteSync
      bufferPt: bufferPt
      fileName: editor.getPath()
      text: editor.getText()
    console.log results
    filteredResults = fuzzaldrin.filter results, prefix, key: "name"
    suggestions = []
    for result in filteredResults
      suggestions.push {word: result.name, label: result.type, prefix: prefix}
    suggestions
