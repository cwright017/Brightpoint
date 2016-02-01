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
  panes: []
  debuggers: {}
  activePane: null

  observeSettingsPane: ->
    atom.config.observe 'brightpoint.markerColor', (newValue) ->
      console.log 'My configuration changed:', newValue

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAll': => @removeAll()
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAllActive': => @removeAllActive()

    openEditors = atom.workspace.getTextEditors()
    @observeSettingsPane()
    # for editor in openEditors when @isBrightscript(editor)

    atom.workspace.observeActivePaneItem (activePane) =>
      activeEditor = atom.workspace.getActiveTextEditor()
      if @isBrightscript(activeEditor)
        if @panes.indexOf(activePane) == -1
          debug = new Debugger()
          debug.scanCurrentPane()
          debug.observeCurrentPane()
          @debuggers[activePane.id] = debug
          @panes.push activePane

          activeEditor.onDidChange ->
            debug.scanCurrentPane()
            console.log 'changed'

        @activePane = activePane


  isBrightscript: (activeEditor) ->
    return activeEditor && activeEditor.getGrammar().scopeName == 'source.brightscript'

  removeAll: ->
    for k,v of @debuggers
      v.destroyAllMarkers()

  removeAllActive: ->
    @debuggers[@activePane.id].destroyAllMarkers()

  consumeStatusBar: (statusBar) ->
    # @statusBarTile = statusBar.addLeftTile(item: text, priority: 100)

  deactivate: ->
    # ...
    # @statusBarTile?.destroy()
    # @statusBarTile = null
