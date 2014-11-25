fuzzaldrin = require 'fuzzaldrin'
{isFlowSource} = require './utils'
utilFlowCommand = require './util-flow-command'

module.exports = (Provider, Suggestion, manager) ->
  class FlowProvider extends Provider

    # TODO Use the asynchronous autocomplete plus API when available

    exclusive: true

    buildSuggestions: ->
      editor = atom.workspace.getActiveEditor()
      return unless isFlowSource editor
      bufferPt = editor.getCursorBufferPosition()
      selection = editor.getSelection()
      prefix = @prefixOfSelection selection
      results = utilFlowCommand.autocompleteSync
        bufferPt: bufferPt
        fileName: editor.getPath()
        text: editor.getText()
      filteredResults = fuzzaldrin.filter results, prefix, key: "name"
      suggestions = []
      for result in filteredResults
        suggestions.push new Suggestion(this, word: result.name, label: result.type, prefix: prefix)
      suggestions
