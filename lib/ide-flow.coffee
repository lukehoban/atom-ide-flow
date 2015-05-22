statusBarItem = require('./status-bar-item')

_pluginManager = null

module.exports =

  activate: ->
    path = require 'path'
    {BufferedProcess} = require 'atom'
    {PluginManager} = require './plugin-manager'
    _pluginManager = new PluginManager()
    atom.commands.add 'atom-workspace',
      "ide-flow:check", ->
        _pluginManager.check()
    atom.commands.add 'atom-workspace',
      "ide-flow:goto-def", ->
        _pluginManager.gotoDefinition()

  consumeStatusBar: (statusBar) ->
    statusBarItem.init(statusBar)

  deactivate: ->
    _pluginManager.deactivate()
    _pluginManager = null
    atom.workspaceView.off 'ide-flow:check'
    statusBarItem.cleanUp()

  provide: ->
    require './flow-autocomplete-provider'

  config:
    checkOnFileSave:
      type: 'boolean'
      default: true
    expressionTypeInterval:
      type: 'integer'
      default: 300
    flowPath:
      type: 'string'
      default: ''
