{CompositeDisposable} = require 'atom'
$ = require 'jquery'

module.exports =
class Debugger
  @markerLayer:  null
  @editor: null
  @editorElement: null
  @gutter: null
  @unsubscribe: null

  constructor: ->
    @editor = atom.workspace.getActiveTextEditor()
    @markerLayer = @editor.addMarkerLayer({options: {maintainHistory: true}})
    @editorElement = atom.views.getView @editor
    @gutter = @editorElement.shadowRoot.querySelector('.gutter')

  unobservePane: ->
    console.log "unsubscribe"
    @unsubscribe()

  observeCurrentPane: =>
    @unsubscribe = $(@gutter).on 'click', (event) =>
      if @editor.getGrammar().scopeName == 'source.brightscript'
        current = @editor.getCursorBufferPosition()
        current.row -= 1
        lineMarker = @getMarkersForLine(current)

        if lineMarker.length
          @deleteMarker(lineMarker[0])
        else
          @createMarker(current)

        @editor.decorateMarkerLayer(@markerLayer, {type: 'line-number', class: 'red-circle' })

  destroyAllMarkers: ->
    markers = @markerLayer.getMarkers()

    for marker in markers
      @deleteMarker(marker)

  getMarkersForLine: (position) ->
    return @markerLayer.findMarkers(containsBufferPosition: position)

  deleteMarker: (marker) ->
    @editor.selectMarker(marker)
    @editor.deleteLine()
    marker.destroy()

  createMarker: (position) ->
    @editor.moveUp(0)
    @editor.insertNewlineAbove()
    @editor.insertText 'STOP'
    @markerLayer.markBufferPosition(position)
