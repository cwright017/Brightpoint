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

          if event.toElement.className.indexOf('folded') == -1
            if lineMarker.length
              @deleteMarker(lineMarker[0])
            else
              @createMarker(current.row)
          else
            @editor.unfoldBufferRow(current.row+1)

  scanEditor: ->
    @editor.scan /\bSTOP\b/g, ({range}) =>
      @editor.scanInBufferRange /^[^']*\bSTOP\b/, [[range.start.row, 0], [range.end.row, Infinity]], ({range}) =>
        marker = @markBuffer(range, true) unless @getMarkersForLine(range.start).length

        if marker
          @observers.add marker.onDidChange ({isValid}) ->
            marker.destroy() unless isValid

  destroyAllMarkers: ->
    @deleteMarker(marker) for marker in @markerLayer.getMarkers()

  getMarkersForLine: (position) ->
    return @markerLayer.findMarkers(startBufferRow: position.row)

  deleteMarker: (marker) ->
    @editor.selectMarker(marker)
    @editor.setTextInBufferRange(marker.getBufferRange(), '')
    @editor.deleteLine() if marker.getProperties().newLine
    marker.destroy()

  createMarker: (bufferRow) ->
    @editor.moveUp(0)
    if @editor.lineTextForBufferRow(bufferRow)
      @editor.insertNewlineAbove()
      newLine = true

    @editor.insertText 'STOP'

    range = [[bufferRow, 0], [bufferRow, Infinity]]
    marker = @markBuffer(range, newLine)

    @observers.add marker.onDidChange ({isValid}) ->
      marker.destroy() unless isValid

  markBuffer: (range, newLine=false) ->
    return @markerLayer.markBufferRange(range, {invalidate: 'touch', newLine: newLine})
