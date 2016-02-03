{CompositeDisposable} = require 'atom'
$ = require 'jquery'

module.exports =
class Debugger
  @markerLayer: null
  @editor: null
  @editorElement: null
  @gutter: null
  @observers: null

  constructor: (@editor) ->
    @observers = new CompositeDisposable
    @markerLayer = @editor.addMarkerLayer({options: {maintainHistory: true}})

    @editorElement = atom.views.getView @editor
    @gutter = @editorElement.shadowRoot.querySelector('.gutter')
    @editor.decorateMarkerLayer(@markerLayer, {type: 'line-number', class: 'red-circle' })

  destroy: ->
    @observers.dispose()
    @markerLayer.destroy()
    $(@gutter).off 'click', '.line-number'

  observeEditor: =>
    $(@gutter).on 'click', '.line-number', (event) =>
        if event.toElement.className != 'icon-right'
          current = @editor.getCursorBufferPosition()
          current.row -= 1
          lineMarker = @getMarkersForLine(current)

          x = event.toElement.className.indexOf 'folded'

          if x == -1
            if lineMarker.length
              @deleteMarker(lineMarker[0])
            else
              @createMarker(current.row)
          else
            @editor.unfoldBufferRow(current.row+1)

  scanEditor: ->
    @editor.scan /\bSTOP\b/g, ({range}) =>
      @markBuffer(range) unless @getMarkersForLine(range.start).length

  destroyAllMarkers: ->
    @deleteMarker(marker) for marker in @markerLayer.getMarkers()

  getMarkersForLine: (position) ->
    return @markerLayer.findMarkers(startBufferRow: position.row)

  deleteMarker: (marker) ->
    @editor.selectMarker(marker)
    @editor.deleteLine()
    marker.destroy()

  createMarker: (bufferRow) ->
    @editor.moveUp(0)
    @editor.insertNewlineAbove()
    @editor.insertText 'STOP'
    range = [[bufferRow, 0], [bufferRow, 10]]
    marker = @markBuffer range

    @observers.add marker.onDidChange ({isValid}) ->
      marker.destroy() unless isValid

  markBuffer: (range) ->
    return @markerLayer.markBufferRange(range, {invalidate: 'inside'})
