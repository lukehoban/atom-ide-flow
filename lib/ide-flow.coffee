path = require 'path'
{BufferedProcess} = require 'atom'

{PluginManager} = require './plugin-manager'

module.exports =

  activate: ->
    @pluginManager = new PluginManager()

    @servers = {}
    atom.workspaceView.command "ide-flow:check", => @check()

  startServer: ->
    editor = atom.workspace.activePaneItem
    filename = editor.getPath()
    dir = path.dirname filename

    process = new BufferedProcess
      command: '/Users/lukeh/Downloads/flow/flow'
      args: ['server', '--lib', 'lib']
      options: { cwd: dir}
      stdout: (output) -> console.log(output)
      stderr: (output) -> console.log("ERR: " + output)
      exit: (code) -> console.log("Flow exited with #{code}")
    process

  check: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.activePaneItem
    filename = editor.getPath()
    dir = path.dirname filename

    if !@servers[dir] then @servers[dir] = @startServer()

    process = new BufferedProcess
      command: '/Users/lukeh/Downloads/flow/flow'
      args: ['--json']
      options: { cwd: dir}
      stdout: (output) -> console.log(output)
      stderr: (output) -> console.log("ERR: " + output)
      exit: (code) -> console.log("Flow exited with #{code}")
