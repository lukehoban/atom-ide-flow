path = require 'path'

isFlowSource = (editor) ->
  if path.extname(editor.getPath()) is '.js'
    if editor.getTextInBufferRange([[0,0], [100,0]]).match(/@flow/)
      return true
    return false
  return false

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

module.exports = {
  isFlowSource,
  pixelPositionFromMouseEvent,
  screenPositionFromMouseEvent
}
