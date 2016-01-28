Debugger = require './Debugger'
{CompositeDisposable} = require 'atom'
$ = require 'jquery'


module.exports = BrightPoint =
  subscriptions: null
  panes: []

  observePane: ->
    console.log "new pane - observing"


  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:toggle': => @toggle()

    console.log @panes.length
    # atom.workspace.onDidStopChangingActivePaneItem (pane) ->
    atom.workspace.observeActivePaneItem (activePane) =>
      console.log @panes.indexOf activePane

      if @panes.indexOf(activePane) == -1
        console.log "observing"
        RokuDebug = new Debugger()
        RokuDebug.observeCurrentPane()
      else
        console.log "old pane bra"

      @panes.push activePane
