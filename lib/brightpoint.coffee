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
    textColor:
      title: 'Text Color'
      description: 'Color to use for breakpoint marker text.'
      type: 'color'
      default: '#FFFFFF'

  subscriptions: null

  editors: []
  debuggers: {}

  observeSettingsPane: ->
    @subscriptions.add atom.config.observe 'brightpoint.markerColor', (color) ->
      if $('#brightpoint-style').length == 0
        $("<style type='text/css' id='brightpoint-style'>
          atom-text-editor::shadow .gutter .line-number.red-circle{
            color: " + atom.config.get('brightpoint.markerColor').toHexString() + ";
            background-color: " + color.toHexString() + ";
          }
        </style>").appendTo("head");
      else
        $('#brightpoint-style').html(
          "atom-text-editor::shadow .gutter .line-number.red-circle{
            color: " + atom.config.get('brightpoint.markerColor').toHexString() + ";
            background-color: " + color.toHexString() + ";
          }")

    @subscriptions.add atom.config.observe 'brightpoint.textColor', (color) ->
      if $('#brightpoint-style').length == 0
        $("<style type='text/css' id='brightpoint-style'>
          atom-text-editor::shadow .gutter .line-number.red-circle{
            color: " + color.toHexString() + ";
            background-color: " + atom.config.get('brightpoint.markerColor').toHexString() + ";
          }
        </style>").appendTo("head");
      else
        $('#brightpoint-style').html(
          "atom-text-editor::shadow .gutter .line-number.red-circle{
            color: " + color.toHexString() + ";
            background-color: " + atom.config.get('brightpoint.markerColor').toHexString() + ";
          }")

  registerCommands: ->
    @subscriptions = new CompositeDisposable
    # @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAll': => @removeAll()
    # @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAllActive': => @removeAllActive()

  activate: (state) ->
    @registerCommands()
    @observeSettingsPane()

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      if @isBrightscript(editor.getGrammar())
        @createEditorObject(editor)
        @debuggers[editor.id].debugger.scanEditor()

        @debuggers[editor.id].observers.add editor.onDidStopChanging =>
          @debuggers[editor.id].debugger.scanEditor()

      @subscriptions.add editor.onDidChangeGrammar (grammar) =>
        if @debuggers[editor.id]
          @removeEditorObject(editor)
        else if !@debuggers[editor.id] && @isBrightscript(grammar)
          @createEditorObject(editor)

          @debuggers[editor.id].observers.add editor.onDidStopChanging =>
            @debuggers[editor.id].debugger.scanEditor()

    @subscriptions.add atom.workspace.onWillDestroyPaneItem (paneItem) =>
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
    delete @debuggers[editor.id]

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
  
  deactivate: ->
    for k,v of @debuggers
      v.debugger?.destroy()
      v.debugger = null
      v.observers?.dispose()
      v.observers = null
      delete @debuggers[k]

    @subscriptions.dispose()

    # @statusBarTile?.destroy()
    # @statusBarTile = null
