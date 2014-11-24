{EditorControl} = require './editor-control'
utilFlowCommand = require('./util-flow-command')
{isFlowSource} = require('./utils')

fuzzaldrin = require "fuzzaldrin"
createAutocompleteProvider = (Provider, Suggestion, manager) ->
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

class PluginManager
  constructor: () ->
    @checkResults = []

    # Defer subscribing the editors until autocomplete is loaded
    # TODO could avoid this delay by just doing the autocomplete registion late
    atom.packages.activatePackage("autocomplete-plus")
      .then (pkg) =>
        @autocomplete = pkg.mainModule
        FlowProvider = createAutocompleteProvider @autocomplete.Provider, @autocomplete.Suggestion, this
        @controlSubscription = atom.workspaceView.eachEditorView (editorView) =>
          editorView.flowController = new EditorControl(editorView, this)
          editorView.flowAutocomplete = new FlowProvider(editorView)
          @autocomplete.registerProviderForEditorView editorView.flowAutocomplete, editorView

  deactivate: () ->
    for editorView in atom.workspaceView.getEditorViews()
      editorView.flowController?.deactivate()
      editorView.flowController = null
      @autocomplete.unregisterProvider editorView.flowAutocomplete
      editorView.flowAutocomplete = null

    @controlSubscription?.off()
    @controlSubscription = null

  gotoDefinition: ->
    editor = atom.workspace.getActiveEditor()
    bufferPt = editor.getCursorBufferPosition()
    utilFlowCommand.getDef
      bufferPt: bufferPt
      fileName: editor.getPath()
      onResult: (result) ->
        if result.path? and result.path isnt ""
          promise = atom.workspace.open result.path
          promise.then (editor) ->
            editor.setCursorBufferPosition [result.line - 1, result.start - 1]
            editor.scrollToCursorPosition()
        else
          console.log("Could not go to definition")

  check: ->
    return if @checkTurnedOff? and @checkTurnedOff
    fileName = atom.workspaceView.getActiveView()?.getEditor().getPath()
    return unless fileName?

    utilFlowCommand.check
      fileName: fileName
      onResult: (result) =>
        # Massage results
        errors = result.errors.map ((parts) ->
          err = parts.message[0]
          err.descr = parts.message.reduce ((acc, x) ->
            acc + " " + x.descr
          ), ""
          err
        )
        @checkResults = errors #result.errors.reduce ((sofar, x) -> sofar.concat x.message), []
        @updateAllEditorViewsWithResults()

  # Update every editor view with results
  updateAllEditorViewsWithResults: ->
    for editorView in atom.workspaceView.getEditorViews()
      editorView.flowController?.resultsUpdated()

  typeAtPos: ({bufferPt, fileName, text, onResult}) ->
    utilFlowCommand.typeAtPos
      fileName: fileName
      bufferPt: bufferPt
      onResult: onResult
      text: text


module.exports = { PluginManager }
