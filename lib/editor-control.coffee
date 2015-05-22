path = require 'path'
$ = require 'jquery'
{BufferedProcess, CompositeDisposable} = require 'atom'
{Subscriber} = require 'emissary'
{TooltipView} = require './tooltip-view'
{isFlowSource, pixelPositionFromMouseEvent, screenPositionFromMouseEvent, getElementsByClass} = require './utils'
statusBarItem = require './status-bar-item'

class EditorControl
  constructor: (@editor, @manager) ->
    @checkMarkers = []
    @disposables = new CompositeDisposable

    @editorView = atom.views.getView(@editor);
    @gutter = $(getElementsByClass(@editorView, '.gutter'))
    @scroll = $(getElementsByClass(@editorView, '.scroll-view'))

    @subscriber = new Subscriber()

    # event for editor updates
    @editor.onDidDestroy =>
      @deactivate()

    # buffer events for automatic check
    buffer = @editor.getBuffer()
    @disposables.add buffer.onDidSave () =>
      return unless isFlowSource @editor

      # TODO if uri was changed, then we have to remove all current markers
      workspaceElement = atom.views.getView(atom.workspace)
      if atom.config.get('ide-flow.checkOnFileSave')
        atom.commands.dispatch workspaceElement, 'ide-flow:check'

    # show expression type if mouse stopped somewhere
    @subscriber.subscribe @scroll, 'mousemove', (e) =>
      @clearExprTypeTimeout()
      @exprTypeTimeout = setTimeout (=>
        @showExpressionType e
      ), 100
    @subscriber.subscribe @scroll, 'mouseout', (e) =>
      @clearExprTypeTimeout()

    # mouse movement over gutter to show check results
    @subscriber.subscribe @gutter, 'mouseenter', ".ide-flow-error", (e) =>
      @showCheckResultByMouseEvent e
    @subscriber.subscribe @gutter, 'mouseleave', ".ide-flow-error", (e) =>
      @hideCheckResult()
    @subscriber.subscribe @gutter, 'mouseleave', (e) =>
      @hideCheckResult()

    # cursor movements show check results when appropriate
    @disposables.add @editor.onDidChangeCursorPosition (e) =>
      @showCheckResultByCursorChange e

    atom.commands.dispatch atom.views.getView(atom.workspace), 'ide-flow:check'

    # update all results from manager
    @resultsUpdated()

  deactivate: ->
    @clearExprTypeTimeout()
    #@hideCheckResult()
    @subscriber.unsubscribe()
    @disposables.dispose()
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

    pixelPt = pixelPositionFromMouseEvent(@editor, e)
    screenPt = @editor.screenPositionForPixelPosition(pixelPt)
    bufferPt = @editor.bufferPositionForScreenPosition(screenPt)
    nextCharPixelPt = @editorView.pixelPositionForBufferPosition([bufferPt.row, bufferPt.column + 1])

    return if pixelPt.left >= nextCharPixelPt.left

    # find out show position
    offset = @editor.getLineHeightInPixels() * 0.7
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
      text: @editor.getText()
      onResult: (result) =>
        @exprTypeTooltip?.updateText(result.type)

  hideExpressionType: ->
    if @exprTypeTooltip?
      @exprTypeTooltip.remove()
      @exprTypeTooltip = null

  resultsUpdated: ->
    @destroyMarkers()
    @markerFromCheckResult(err) for err in @manager.checkResults
    @renderResults()

  destroyMarkers: ->
    m.marker.destroy() for m in @checkMarkers
    @checkMarkers = []

  markerFromCheckResult: (err) ->
    return unless err.path is @editor.getPath()
    marker = @editor.markBufferRange [[err.line-1, err.start-1],[err.endline-1, err.end]], invalidate: 'never'
    @checkMarkers.push({ marker, desc: err.descr })

  renderResults: ->
    @decorateMarker(m) for m in @checkMarkers

  decorateMarker: ({marker}) ->
    @editor.decorateMarker marker, type: 'line-number', class: 'ide-flow-error'
    @editor.decorateMarker marker, type: 'highlight', class: 'ide-flow-error'
    @editor.decorateMarker marker, type: 'line', class: 'ide-flow-error'

    # show check result when mouse over gutter icon
  showCheckResultByMouseEvent: (e) ->
    @hideCheckResult()
    row = @editor.bufferPositionForScreenPosition(screenPositionFromMouseEvent(@editor, e)).row

    foundResult = @findCheckResultForRow(row)
    # append tooltip if result found
    return unless foundResult?

    # create show position
    targetRect = e.currentTarget.getBoundingClientRect()
    offset = @editor.getLineHeightInPixels() * 0.3
    rect =
      left: targetRect.left - offset
      right: targetRect.right + offset
      top: targetRect.top - offset
      bottom: targetRect.bottom + offset

    @checkResultTooltip = new TooltipView(rect, foundResult)

  showCheckResultByCursorChange: (e) ->
    row = e.newBufferPosition.row

    foundResult = @findCheckResultForRow(row)

    if !foundResult
      statusBarItem.clear()
    else
      statusBarItem.setText(foundResult)

  findCheckResultForRow: (row) ->
    foundResult = null
    for {marker, desc} in @checkMarkers
      if marker.getHeadBufferPosition().row is row
        foundResult = desc
        break
    return foundResult

  hideCheckResult: ->
    if @checkResultTooltip?
      @checkResultTooltip.remove()
      @checkResultTooltip = null

module.exports = { EditorControl }
