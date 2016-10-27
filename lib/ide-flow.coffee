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

  deactivate: ->
    _pluginManager.deactivate()
    _pluginManager = null

  provide: ->
    require './flow-autocomplete-provider'

  config:
    checkAllFiles:
      type: 'boolean'
      default: false
    checkOnFileSave:
      type: 'boolean'
      default: true
    expressionTypeInterval:
      type: 'integer'
      default: 300
    flowPath:
      type: 'string'
      default: ''
