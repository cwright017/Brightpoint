Debugger = require './Debugger'
{CompositeDisposable} = require 'atom'

module.exports = BrightPoint =
  config:
    markerColor:
      title: 'Marker Color'
    #   description: 'Color to use for breakpoint marker.'
    #   type: 'color'
    #   default: '#DB1D1D'

  subscriptions: null

  editors: []
  debuggers: {}

  observeSettingsPane: ->
    # atom.config.observe 'brightpoint.markerColor', (newValue) ->
    #   console.log 'My configuration changed:', newValue

  registerCommands: ->
    @subscriptions = new CompositeDisposable
    # @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAll': => @removeAll()
    # @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAllActive': => @removeAllActive()

  activate: (state) ->
    @registerCommands()
    @observeSettingsPane()

    atom.workspace.observeTextEditors (editor) =>
      if @isBrightscript(editor.getGrammar())
        @createEditorObject(editor)

        @debuggers[editor.id].observers.add editor.onDidStopChanging =>
          @debuggers[editor.id].debugger.scanEditor()

      editor.onDidChangeGrammar (grammar) =>
        if @debuggers[editor.id]
          @removeEditorObject(editor)
        else if !@debuggers[editor.id] && @isBrightscript(grammar)
          @createEditorObject(editor)

          @debuggers[editor.id].observers.add editor.onDidChange =>
            @debuggers[editor.id].debugger.scanEditor()

    atom.workspace.onWillDestroyPaneItem (paneItem) =>
      @removeEditorObject paneItem.item if atom.workspace.isTextEditor paneItem.item

  createEditorObject: (editor) ->
    @debuggers[editor.id] = {
      editor: editor,
      debugger: new Debugger(editor)
      observers: new CompositeDisposable
    }

    @debuggers[editor.id].debugger.observeEditor()

  removeEditorObject: (editor) ->
    # remove markers when closed?
    @debuggers[editor.id]?.debugger.destroy()
    @debuggers[editor.id]?.observers.dispose()
    delete @debuggers[editor.id]?

  getEditors: ->
    return atom.workspace.getTextEditors()

  isBrightscript: (grammar) ->
    return grammar?.scopeName == 'source.brightscript'

  # removeAll: ->
  #   for k,v of @debuggers
  #     v.debugger.destroyAllMarkers()

  #
  # removeAllActive: ->
  #   @debuggers[@activePane.id].destroyAllMarkers()
  #
  # consumeStatusBar: (statusBar) ->
  #   # @statusBarTile = statusBar.addLeftTile(item: text, priority: 100)
  #
  # deactivate: ->
  #   # ...
  #   # @statusBarTile?.destroy()
  #   # @statusBarTile = null
