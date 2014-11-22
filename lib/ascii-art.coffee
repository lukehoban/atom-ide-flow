{BufferedProcess} = require 'atom'
{Subscriber} = require 'emissary'
path = require 'path'

{TooltipView} = require './tooltip-view'

# pixel position from mouse event
pixelPositionFromMouseEvent = (editorView, event) ->
  {clientX, clientY} = event
  linesClientRect = editorView.find('.lines')[0].getBoundingClientRect()
  top = clientY - linesClientRect.top
  left = clientX - linesClientRect.left
  {top, left}

# screen position from mouse event
screenPositionFromMouseEvent = (editorView, event) ->
  editorView.getModel().screenPositionForPixelPosition(pixelPositionFromMouseEvent(editorView, event))

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

class EditorControl
  constructor: (@editorView, @manager) ->
    @editor = @editorView.getEditor()
    @gutter = @editorView.gutter
    @scroll = @editorView.find('.scroll-view')

    @subscriber = new Subscriber()

    # event for editor updates
    @subscriber.subscribe @editorView, 'editor:will-be-removed', =>
      @deactivate()

    # buffer events for automatic check
    # @subscriber.subscribe @editor.getBuffer(), 'saved', (buffer) =>
    #   return unless isHaskellSource buffer.getUri()
    #
    #   # TODO if uri was changed, then we have to remove all current markers
    #
    #   if atom.config.get('ide-haskell.checkOnFileSave')
    #     atom.workspaceView.trigger 'ide-haskell:check-file'
    #   if atom.config.get('ide-haskell.lintOnFileSave')
    #     atom.workspaceView.trigger 'ide-haskell:lint-file'

    # show expression type if mouse stopped somewhere
    @subscriber.subscribe @scroll, 'mousemove', (e) =>
      @clearExprTypeTimeout()
      @exprTypeTimeout = setTimeout (=>
        @showExpressionType e
      ), 100
    @subscriber.subscribe @scroll, 'mouseout', (e) =>
      @clearExprTypeTimeout()

    # mouse movement over gutter to show check results
    # for klass in @className
    #   @subscriber.subscribe @gutter, 'mouseenter', ".#{klass}", (e) =>
    #     @showCheckResult e
    #   @subscriber.subscribe @gutter, 'mouseleave', ".#{klass}", (e) =>
    #     @hideCheckResult()
    # @subscriber.subscribe @gutter, 'mouseleave', (e) =>
    #   @hideCheckResult()

    # update all results from manager
    #@resultsUpdated()

  deactivate: ->
    @clearExprTypeTimeout()
    #@hideCheckResult()
    @subscriber.unsubscribe()
    @editorView.control = undefined

  # helper function to hide tooltip and stop timeout
  clearExprTypeTimeout: ->
    if @exprTypeTimeout?
      clearTimeout @exprTypeTimeout
      @exprTypeTimeout = null
    @hideExpressionType()

  # get expression type under mouse cursor and show it
  showExpressionType: (e) ->
    # TODO Check if it's a JS file and that it has Flow enabled??
    #return unless isHaskellSource(@editor.getUri()) and not @exprTypeTooltip?

    pixelPt = pixelPositionFromMouseEvent(@editorView, e)
    screenPt = @editor.screenPositionForPixelPosition(pixelPt)
    bufferPt = @editor.bufferPositionForScreenPosition(screenPt)
    nextCharPixelPt = @editor.pixelPositionForBufferPosition([bufferPt.row, bufferPt.column + 1])

    return if pixelPt.left > nextCharPixelPt.left

    # find out show position
    offset = @editorView.lineHeight * 0.7
    tooltipRect =
      left: e.clientX
      right: e.clientX
      top: e.clientY - offset
      bottom: e.clientY + offset

    # create tooltip with pending
    @exprTypeTooltip = new TooltipView(tooltipRect)

    # process start
    # @manager.pendingProcessController.start Channel.expressionType, utilGhcMod.type, {
    #   pt: bufferPt
    #   fileName: @editor.getUri()
    #   onResult: (result) =>
    #     @exprTypeTooltip?.updateText(result.type)
    # }
    # This assumes the active pane item is an editor
    filename = @editor.getPath()
    dir = path.dirname filename

    if !@servers then @servers = {}
    if !@servers[dir] then @servers[dir] = @startServer()

    process = new BufferedProcess
      command: '/Users/lukeh/Downloads/flow/flow'
      args: ['type-at-pos', filename, bufferPt.row + 1, bufferPt.column + 1, '--json']
      options: { cwd: dir}
      stdout: (output) =>
        result = JSON.parse output
        @exprTypeTooltip?.updateText result.type
        console.log(output)
      stderr: (output) -> console.log("ERR: " + output)
      exit: (code) -> console.log("Flow exited with #{code}")

  startServer: ->
    filename = @editor.getPath()
    dir = path.dirname filename

    process = new BufferedProcess
      command: '/Users/lukeh/Downloads/flow/flow'
      args: ['server', '--lib', 'lib']
      options: { cwd: dir}
      stdout: (output) -> console.log(output)
      stderr: (output) -> console.log("ERR: " + output)
      exit: (code) -> console.log("Flow exited with #{code}")
    process

  hideExpressionType: ->
    if @exprTypeTooltip?
      @exprTypeTooltip.remove()
      @exprTypeTooltip = null

module.exports =

  activate: ->
    @pluginManager = new PluginManager()

    @servers = {}
    atom.workspaceView.command "ascii-art:convert", => @check()

  startServer: ->
    editor = atom.workspace.activePaneItem
    filename = editor.getPath()
    dir = path.dirname filename

    process = new BufferedProcess
      command: '/Users/lukeh/Downloads/flow/flow'
      args: ['server', '--lib', 'lib']
      options: { cwd: dir}
      stdout: (output) -> console.log(output)
      stderr: (output) -> console.log("ERR: " + output)
      exit: (code) -> console.log("Flow exited with #{code}")
    process

  check: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.activePaneItem
    filename = editor.getPath()
    dir = path.dirname filename

    if !@servers[dir] then @servers[dir] = @startServer()

    process = new BufferedProcess
      command: '/Users/lukeh/Downloads/flow/flow'
      args: ['--json']
      options: { cwd: dir}
      stdout: (output) -> console.log(output)
      stderr: (output) -> console.log("ERR: " + output)
      exit: (code) -> console.log("Flow exited with #{code}")
