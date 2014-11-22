{EditorControl} = require './editor-control'
utilFlowCommand = require('./util-flow-command')

class PluginManager
  constructor: () ->
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

  check: ->
    #utilFlowCommand.check()

    return if @checkTurnedOff? and @checkTurnedOff
    fileName = atom.workspaceView.getActiveView()?.getEditor().getPath()
    return unless fileName?

    @outputView?.pendingCheck()

    utilFlowCommand.check
      fileName: fileName
      onResult: (result) =>
        @checkResults = result.errors.reduce ((sofar, x) -> sofar.concat x.message), []
        @updateAllEditorViewsWithResults()

  # Update every editor view with results
  updateAllEditorViewsWithResults: ->
    for editorView in atom.workspaceView.getEditorViews()
      editorView.flowController?.resultsUpdated()

  typeAtPos: ({bufferPt, fileName, cwd, onResult}) ->
    utilFlowCommand.typeAtPos
      fileName: fileName
      bufferPt: bufferPt
      onResult: onResult


module.exports = { PluginManager }
