path = require 'path'
{BufferedProcess} = require 'atom'
{Subscriber} = require 'emissary'
{TooltipView} = require './tooltip-view'
{isFlowSource, pixelPositionFromMouseEvent, screenPositionFromMouseEvent} = require './utils'

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
    @subscriber.subscribe @editor.getBuffer(), 'saved', (buffer) =>
      return unless isFlowSource buffer

      # TODO if uri was changed, then we have to remove all current markers

      if atom.config.get('ide-flow.checkOnFileSave')
        atom.workspaceView.trigger 'ide-flow:check'

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
    return unless isFlowSource(@editor) and not @exprTypeTooltip?

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

    @manager.typeAtPos
      bufferPt: bufferPt
      fileName: @editor.getPath()
      onResult: (result) =>
        @exprTypeTooltip?.updateText(result.type)

  hideExpressionType: ->
    if @exprTypeTooltip?
      @exprTypeTooltip.remove()
      @exprTypeTooltip = null

module.exports = { EditorControl }
