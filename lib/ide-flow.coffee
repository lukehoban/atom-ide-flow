path = require 'path'
{BufferedProcess} = require 'atom'

{PluginManager} = require './plugin-manager'

_pluginManager = null

module.exports =

  activate: ->
    _pluginManager = new PluginManager()
    atom.workspaceView.command "ide-flow:check", ->
      _pluginManager.check()

  deactivate: ->
    _pluginManager.deactivate()
    _pluginManager = null
    atom.workspaceView.off 'ide-flow:check'
