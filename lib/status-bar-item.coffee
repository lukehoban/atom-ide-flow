module.exports =
  init: (statusBar) ->
    @statusBar = statusBar

  cleanUp: ->
    @statusBarTile?.destroy()
    @statusBarTile = null

  setText: (text) ->
    span = document.createElement('span')
    span.textContent = text
    @statusBarTile = @statusBar?.addLeftTile(item: span, priority: 1000)

  clear: ->
    @statusBarTile?.destroy()
    @statusBarTile = null
