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

    @markerLayer.onDidUpdate =>
      console.log @markerLayer.getMarkers()



    @editorElement = atom.views.getView @editor
    @gutter = @editorElement.shadowRoot.querySelector('.gutter')
    @editor.decorateMarkerLayer(@markerLayer, {type: 'line-number', class: 'red-circle' })

  unobservePane: ->
    @unsubscribe()

  observeCurrentPane: =>
    @unsubscribe = $(@gutter).on 'click', '.line-number', (event) =>
        if event.toElement.className != 'icon-right'
          current = @editor.getCursorBufferPosition()
          current.row -= 1
          lineMarker = @getMarkersForLine(current)

          if lineMarker.length
            @deleteMarker(lineMarker[0])
          else
            @createMarker(current)

  scanCurrentPane: ->
    @editor.scan /\bSTOP\b/g, ({range}) =>
      @markerLayer.markBufferPosition(range.start, {invalidate: 'inside'})

  destroyAllMarkers: ->
    markers = @markerLayer.getMarkers()

    for marker in markers
      @deleteMarker(marker)

  getMarkersForLine: (position) ->
    return @markerLayer.findMarkers(startBufferRow: position.row)

  deleteMarker: (marker) ->
    @editor.selectMarker(marker)
    @editor.deleteLine()
    marker.destroy()

  createMarker: (position) ->
    @editor.moveUp(0)
    @editor.insertNewlineAbove()
    @editor.insertText 'STOP'
    @markerLayer.markBufferPosition(position, {invalidate: 'inside'})
