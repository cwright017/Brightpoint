Debugger = require './Debugger'
{CompositeDisposable} = require 'atom'
$ = require 'jquery'


module.exports = BrightPoint =
  config:
    markerColor:
      title: 'Marker Color'
      description: 'Color to use for breakpoint marker.'
      type: 'color'
      default: '#DB1D1D'

  subscriptions: null

  editors: []
  debuggers: {}

  observeSettingsPane: ->
    atom.config.observe 'brightpoint.markerColor', (newValue) ->
      console.log 'My configuration changed:', newValue

  registerCommands: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAll': => @removeAll()
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAllActive': => @removeAllActive()

  activate: (state) ->
    @registerCommands()
    @observeSettingsPane()

    atom.workspace.observeTextEditors (editor) =>
      if @isBrightscript(editor.getGrammar())
        @createEditorObject(editor)

        @debuggers[editor.id].observers.add editor.onDidChange ->
          console.log 'changed'

      editor.onDidChangeGrammar (grammar) =>
        if @debuggers[editor.id]
          @removeEditorObject(editor)
        else if !@debuggers[editor.id] && @isBrightscript(grammar)
          @createEditorObject(editor)

          @debuggers[editor.id].observers.add editor.onDidChange ->
            console.log 'changed'

        console.log @debuggers

    atom.workspace.onWillDestroyPaneItem (paneItem) =>
      @removeEditorObject paneItem.item if atom.workspace.isTextEditor paneItem.item 

      # if @isBrightscript(activeEditor)
      #   if @panes.indexOf(activePane) == -1
      #     debug = new Debugger()
      #     debug.scanCurrentPane()
      #     debug.observeCurrentPane()
      #     @debuggers[activePane.id] = debug
      #     @panes.push activePane


  createEditorObject: (editor) ->
    console.log 'new bs'
    @debuggers[editor.id] = {
      editor: editor,
      debugger: new Debugger(editor)
      observers: new CompositeDisposable
    }

    @debuggers[editor.id].debugger.observeEditor()

  removeEditorObject: (editor) ->
    # unsubscribe to events in debugger
    console.log 'bs removed' + editor.id
    @debuggers[editor.id].debugger.destroy()
    @debuggers[editor.id].observers.dispose()
    delete @debuggers[editor.id]

  getEditors: ->
    return atom.workspace.getTextEditors()

  isBrightscript: (grammar) ->
    return grammar?.scopeName == 'source.brightscript'

  # removeAll: ->
  #   for k,v of @debuggers
  #     v.destroyAllMarkers()
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
