function init() as Void
	m.singleLineLength = 15
	m.singleLineHeight = 45
	m.buttonPlay = m.top.findNode("buttonPlay")
end function

function generate()
	m.top.findNode("title").text = m.top.content.title
	m.top.findNode("packshotImage").uri = m.top.content.packshotUri
	m.top.findNode("synopsis").text = m.top.content.synopsis
	m.top.findNode("backgroundImage").uri = m.top.content.backgroundImageUri
    m.top.findNode("metaDataComponent").content = m.top.content.metaDataArray

    m.top.findNode("buttonPlay").text = getTextById("pdp.button.watchnow")
    m.top.findNode("button2").text = getTextById("pdp.button.more")
    m.top.findNode("button3").text = getTextById("pdp.button.button3")

    b2 = m.top.findNode("button2")
    b3 = m.top.findNode("button3")

    m.buttonPlay.labelTrans = "[30, 0]"
    b2.labelTrans = "[30, 0]"
    b3.labelTrans = "[30, 0]"

    m.buttonPlay.labelWidth = m.buttonPlay.width

    m.buttonPlay.text = getTextById("pdp.button.watchnow")
    b2.text = getTextById("pdp.button.more")
    b3.text = getTextById("pdp.button.button3")

    b2.width = b2.labelWidth
    b3.width = b3.labelWidth

    m.top.findNode("directorsLabel").text = getTextById("pdp.label.directors")
    m.top.findNode("actorsLabel").text = getTextById("pdp.label.actors")

	directorsChanged()
	actorsChanged()
	m.top.focusable = true
	m.top.setFocus(true)

	m.top.findNode("buttonPlay").handleFocus = true

	resizeButton(b2)
	resizeButton(b3)
end function

function setFont(node as Object, size=20 as Integer)
	font  = CreateObject("roSGNode", "Font")
	font.uri = "pkg:/fonts/regular.ttf"
	font.size = size
	node.font = font
end function

function directorsChanged()
	directors = m.top.content.directorsArray
	directorLayoutGroup = m.top.findNode("directorLayoutGroup")
	for each director in directors
		directorLayoutGroup.appendChild(formatLabel(director))
	end for
end function

function actorsChanged()
	actors = m.top.content.actorsArray
	actorsLayoutGroup = m.top.findNode("actorsLayoutGroup")
	for each actor in actors
		actorsLayoutGroup.appendChild(formatLabel(actor))
	end for
end function

function formatLabel(labelText as String) as Object
	newNode = createObject("roSGNode", "Label")
	newNode.text = labelText.trim()
	newNode.wrap = "true"
	newNode.color = "#E9E9E9"
	newNode.width = "180"
	newNode.lineSpacing = "-5"
	setFont(newNode, 20)
	return newNode
end function

function resizeButton(b as Object) as Void
	if len(b.text) < m.singleLineLength
		b.height = m.singleLineHeight
	end if
end function
