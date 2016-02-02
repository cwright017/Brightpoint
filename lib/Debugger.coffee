{CompositeDisposable} = require 'atom'
$ = require 'jquery'

module.exports =
class Debugger
  @markerLayer: null
  @editor: null
  @editorElement: null
  @gutter: null
  @observers: null

  constructor: (editor) ->
    @observers = new CompositeDisposable
    @editor = editor
    @markerLayer = @editor.addMarkerLayer({options: {maintainHistory: true}})

    @observers.add @markerLayer.onDidUpdate =>
      console.log @markerLayer.getMarkers()

    @editorElement = atom.views.getView @editor
    @gutter = @editorElement.shadowRoot.querySelector('.gutter')
    @editor.decorateMarkerLayer(@markerLayer, {type: 'line-number', class: 'red-circle' })

  destroy: ->
    console.log "destroying observers for " + @editor.id

    @observers.dispose()
    $(@gutter).off 'click', '.line-number'
    @markerLayer.destroy()

  observeEditor: =>
    console.log "Observing " + @editor.id

    $(@gutter).on 'click', '.line-number', (event) =>
        if event.toElement.className != 'icon-right'
          current = @editor.getCursorBufferPosition()
          current.row -= 1
          lineMarker = @getMarkersForLine(current)

          if lineMarker.length
            @deleteMarker(lineMarker[0])
          else
            @createMarker(current)

  scanEditor: ->
    @editor.scan /\bSTOP\b/g, ({range}) =>
      @markerLayer.markBufferPosition(range.start, {invalidate: 'inside'})

  destroyAllMarkers: ->
    @deleteMarker(marker) for marker in @markerLayer.getMarkers()

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
