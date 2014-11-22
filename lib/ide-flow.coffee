path = require 'path'
{BufferedProcess} = require 'atom'

{PluginManager} = require './plugin-manager'

_pluginManager = null

module.exports =

  activate: ->
    _pluginManager = new PluginManager()
    atom.workspaceView.command "ide-flow:check", ->
      _pluginManager.check()
    atom.workspaceView.command "ide-flow:goto-def", ->
      _pluginManager.gotoDefinition()

  deactivate: ->
    _pluginManager.deactivate()
    _pluginManager = null
    atom.workspaceView.off 'ide-flow:check'

  configDefaults:
    checkOnFileSave: true,
    expressionTypeInterval: 300
