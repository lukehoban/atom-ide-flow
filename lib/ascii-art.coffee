{BufferedProcess} = require 'atom'
path = require('path')

module.exports =

  activate: ->
    @servers = {}
    atom.workspaceView.command "ascii-art:convert", => @convert()

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

  convert: ->
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
