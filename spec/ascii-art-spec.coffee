{WorkspaceView} = require 'atom'
AsciiArt = require '../lib/ascii-art'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AsciiArt", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('ascii-art')

  describe "when the ascii-art:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.ascii-art')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch atom.workspaceView.element, 'ascii-art:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.ascii-art')).toExist()
        atom.commands.dispatch atom.workspaceView.element, 'ascii-art:toggle'
        expect(atom.workspaceView.find('.ascii-art')).not.toExist()
