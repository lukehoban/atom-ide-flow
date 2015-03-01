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
    atom.workspaceView.off 'ide-flow:check'

  provide: ->
    return {providers: [require './flow-autocomplete-provider']}

  configDefaults:
    checkOnFileSave: true,
    expressionTypeInterval: 300
    flowPath: ""
