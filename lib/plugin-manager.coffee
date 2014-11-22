{EditorControl} = require './editor-control'
utilFlowCommand = require('./util-flow-command')

class PluginManager
  constructor: () ->
    @checkResults = []
    @subsribeEditorViewController()

  deactivate: () ->
    @deleteEditorViewControllers()

  # Subscribe on editor view for attaching controller.
  subsribeEditorViewController: ->
    @controlSubscription = atom.workspaceView.eachEditorView (editorView) =>
      editorView.flowController = new EditorControl(editorView, this)

  deleteEditorViewControllers: ->
    for editorView in atom.workspaceView.getEditorViews()
      editorView.flowController?.deactivate()
      editorView.flowController = null

    @controlSubscription?.off()
    @controlSubscription = null

  gotoDefinition: ->
    editor = atom.workspace.getActiveEditor()
    bufferPt = editor.getCursorBufferPosition()
    @typeAtPos
      bufferPt: bufferPt
      fileName: editor.getPath()
      onResult: (result) ->
        target = result.reasons[0]
        if target?
          promise = atom.workspace.open target.path,
            initialLine: target.line - 1
            initialColumn: target.start - 1
          promise.then (editor) ->
            editor.setCursorBufferPosition [target.line - 1, target.start - 1]
            editor.scrollToCursorPosition()

        else
          console.log("Could not go to definition")

  check: ->
    #utilFlowCommand.check()

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

  typeAtPos: ({bufferPt, fileName, onResult}) ->
    utilFlowCommand.typeAtPos
      fileName: fileName
      bufferPt: bufferPt
      onResult: onResult


module.exports = { PluginManager }
