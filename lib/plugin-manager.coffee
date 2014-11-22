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
    utilFlowCommand.check()

  typeAtPos: ({bufferPt, fileName, cwd,  onResult}) ->
    utilFlowCommand.typeAtPos {fileName, bufferPt, onResult}


module.exports = { PluginManager }
