BrightPointView = require './bright-point-view'
{CompositeDisposable} = require 'atom'
$ = require 'jquery'

module.exports = BrightPoint =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:toggle': => @toggle()

    editor = atom.workspace.getActiveTextEditor()
    markerLayer = editor.addMarkerLayer({options: true})

    @editorElement = atom.views.getView editor
    gutter = @editorElement.shadowRoot.querySelector('.gutter')

    $(gutter).on 'click', (event) ->
      console.log editor.getGrammar().scopeName
      if editor.getGrammar().scopeName == 'source.brightscript'
        current = editor.getCursorBufferPosition()
        current.row -= 1

        console.log current
        console.log markerLayer.getMarkers()
        lineMarker = markerLayer.findMarkers(containsBufferPosition: current)
        console.log lineMarker

        if lineMarker.length
           editor.selectMarker(lineMarker[0])
           editor.deleteLine()
           lineMarker[0].destroy()

        else
          editor.moveUp(0)
          editor.insertNewlineAbove()
          editor.insertText 'STOP'

          newMarker = markerLayer.markBufferPosition(current)
          editor.decorateMarkerLayer(markerLayer, {type: 'line-number', class: 'red-circle' })

    


  toggle: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'bright-point:toggle': => @toggle()

    editor = atom.workspace.getActiveTextEditor()
    markerLayer = editor.addMarkerLayer({options: true})

    @editorElement = atom.views.getView editor
    gutter = @editorElement.shadowRoot.querySelector('.gutter')

    $(gutter).on 'click', (event) ->
      console.log editor.getGrammar().scopeName
      if editor.getGrammar().scopeName == 'source.brightscript'
        current = editor.getCursorBufferPosition()
        current.row -= 1

        console.log current
        console.log markerLayer.getMarkers()
        lineMarker = markerLayer.findMarkers(containsBufferPosition: current)
        console.log lineMarker

        if lineMarker.length
           editor.selectMarker(lineMarker[0])
           editor.deleteLine()
           lineMarker[0].destroy()

        else
          editor.moveUp(0)
          editor.insertNewlineAbove()
          editor.insertText 'STOP'

          newMarker = markerLayer.markBufferPosition(current)
          editor.decorateMarkerLayer(markerLayer, {type: 'line-number', class: 'red-circle' })
