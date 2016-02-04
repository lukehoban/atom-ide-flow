fuzzaldrin = require 'fuzzaldrin'
{isFlowSource} = require './utils'
utilFlowCommand = require './util-flow-command'

functionDetailsToString = ({params, return_type}) =>
  paramParts = (name + ": " + (type || "any") for {name, type} in params)
  paramString = paramParts.join(',')
  "(" + paramString + ") => " + return_type

module.exports =
  selector: '.source.js, .source.jsx'
  disableForSelector: '.source.js .comment'
  getSuggestions: ({editor, bufferPosition, prefix}) ->
    new Promise (resolve) ->
      return resolve [] unless isFlowSource editor
      return resolve [] unless /\S/.test(prefix)
      prefix = "" if prefix is "."
      utilFlowCommand.autocomplete
        bufferPt: bufferPosition
        fileName: editor.getPath()
        text: editor.getText()
        onResult: (results) =>
          console.log results
          filteredResults = fuzzaldrin.filter results.result, prefix, key: "name"
          suggestions = []
          for result in filteredResults
            suggestions.push
              text: result.name
              label: if result.func_details then functionDetailsToString result.func_details else result.type
              type: if result.func_details then 'function' else 'property'
              prefix: prefix
          resolve suggestions
