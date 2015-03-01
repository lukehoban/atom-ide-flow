path = require 'path'

isFlowSource = (editor) ->
  buffer = editor.getBuffer()
  fname = buffer.getUri()
  if path.extname(fname) in ['.js', '.jsx']
    if buffer.lineForRow(0).match(/@flow/)
      return true
    return false
  return false

# pixel position from mouse event
pixelPositionFromMouseEvent = (editor, event) ->
  {clientX, clientY} = event
  elem = atom.views.getView(editor)
  linesClientRect = getElementsByClass(elem, ".lines")[0].getBoundingClientRect()
  top = clientY - linesClientRect.top
  left = clientX - linesClientRect.left
  {top, left}

# screen position from mouse event
screenPositionFromMouseEvent = (editor, event) ->
  editor.screenPositionForPixelPosition(pixelPositionFromMouseEvent(editor, event))

getElementsByClass = (elem,klass) ->
  elem.rootElement.querySelectorAll(klass)

module.exports = {
  isFlowSource,
  pixelPositionFromMouseEvent,
  screenPositionFromMouseEvent,
  getElementsByClass
}
