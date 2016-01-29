Debugger = require './Debugger'
{CompositeDisposable} = require 'atom'
$ = require 'jquery'


module.exports = BrightPoint =
  subscriptions: null
  panes: []
  debuggers: {}
  activePane: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAll': => @removeAll()
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:removeAllActive': => @removeAllActive()

    atom.workspace.observeActivePaneItem (activePane) =>
      if @panes.indexOf(activePane) == -1
        debug = new Debugger()
        debug.observeCurrentPane()
        @debuggers[activePane.id] = debug

      @panes.push activePane
      @activePane = activePane

  removeAll: ->
    for k,v of @debuggers
      v.destroyAllMarkers()

  removeAllActive: ->
    @debuggers[@activePane.id].destroyAllMarkers()
