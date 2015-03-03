isFlowTests = require './fixtures/is-flow-source'
{TextEditor} = require 'atom'
utils = require '../lib/utils'

describe 'is Flow source check', ->
  beforeEach ->
    waitsForPromise ->
      atom.workspace.open 'test.js'
  isFlowTests.forEach (test) ->
    it 'should handle: ' + test.desc, ->
      editor = atom.workspace.getActiveTextEditor()
      editor.setText test.text
      expect(utils.isFlowSource editor).toEqual test.match
  it 'should handle an empty buffer', ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setText ""
    expect(utils.isFlowSource editor).toEqual false
