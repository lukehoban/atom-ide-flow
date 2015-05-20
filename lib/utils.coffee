path = require 'path'

isFlowSource = (editor) ->
  buffer = editor.getBuffer()
  fname = buffer.getUri()
  isFlow = false
  if path.extname(fname) in ['.js', '.jsx']
    if buffer.lineForRow(buffer.nextNonBlankRow -1)?.match(/\/\*/)
      buffer.scan /\/\*(.|\n)*?\*\//, (scan) =>
        isFlow = true if scan.matchText.match(/@flow/)
    if buffer.lineForRow(buffer.nextNonBlankRow -1)?.match(/\/\//)
      buffer.scan /\/\/(.|\n)*?/, (scan) =>
        isFlow = true if scan.lineText.match(/@flow/)
  return isFlow

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
