# Minesweeper
class Minesweeper

  # static properties.

  # public properties.
  # debug flag
  debug: true
  # panel size(width & height)
  panelSize: 20
  # game Type
  gameType: "beginner"
  types:
    "beginner": "初級"
    "medium":   "中級"
    "advance": "上級"

  # private properties.
  # game parameter
  games =
    beginner:
      width:  9
      height: 9
      bom:    10
    medium:
      width:  16
      height: 16
      bom:    40
    advance:
      width:  30
      height: 16
      bom:    99

  # game board object
  boards =
    x:        0
    y:        0
    size:     0
    bom:      0
    bomCount: 0
    openCount:0
    panels:   []

  # public methods.
  constructor: ->
    @setMenu()
    @initialize()

  # initialize method.
  initialize: ->
    for type of games
      if @gameType == type
         boards.x = games[type].width
         boards.y = games[type].height
         boards.bom = games[type].bom
         boards.size = games[type].width * games[type].height

    rands = @getRand()
    for i in [0..boards.size-1]
      bomF = (rands.indexOf(i) != -1) ? true : false
      panel =
        idx: i,
        bom: bomF,
        open: false,
        surround: getSurround(i),
        tag: $("<div>", {
          class: "panel",
          obj: boards.panels[i]
        }).css({width: (@panelSize - 4) + "px", height: (@panelSize - 4) + "px" }),
        click: ->
          if @isOpen()
            @open = true
            return false
          if @isBom()
            @open = true
            gameOver()
            return false

          @open = true
          boards.openCount++
          cnt = 0
          @tag.addClass("safe")
          for i of @surround
            obj = getPanel(@surround[i])
            if obj.isBom()
              cnt++

          if cnt < 1
            @tag.html("")
            for i of @surround
              obj = getPanel(@surround[i])
              if !obj.isOpen()
                obj.click()
          else
            @tag.html(cnt)

          if (boards.openCount + boards.bom) >= boards.size
            alert "CLEAR"
            return false

        isBom: ->
          if @bom
            return true
          else
            return false
        isOpen: ->
          if @open
            return true
          else
            return false

      boards.panels[i] = panel

    @publish()

  gameOver = ->
    for i in [0..boards.size-1]
      obj = getPanel(i)
      if obj.isBom()
        obj.tag.html("S").addClass("bom")
    return false;

  getRand: ->
    p = []
    for s in [0..boards.size-1]
      p[s] = s

    i = p.length
    while(i)
      j = Math.floor(Math.random()*i)
      t = p[--i]
      p[i] = p[j]
      p[j] = t

    idx = []
    for  i in [0..boards.bom-1]
      idx[i] = p[i]
    idx.sort((a, b)->
      return (parseInt(a) > parseInt(b)) ? 1 : -1
    )
    return idx

  publish: ->
    @cleanUp()
    base = $("#gamePanel")

    for i in [0..boards.size-1]
      tag = boards.panels[i].tag
      ((i) ->
        tag.click ->
          boards.panels[i].click()
      )(i)
      tag.appendTo(base)

  cleanUp: ->
    gamePanel = $("#gamePanel")
    if gamePanel.length > 0
      gamePanel.remove()

    $("<div>", {id: "gamePanel"}).css({width: (@panelSize * boards.x) + "px", height: (@panelSize * boards.y)+ "px"}).appendTo("body")

  setMenu: ->
    div = $("<div>", {id: "menu"}).addClass("menu")
    $("<span>", {id: "restart"}).html("RESTART").addClass("active").appendTo(div)
    for i of @types
      $("<span>", {id: i}).html(@types[i]).addClass("button").addClass("active").appendTo(div)

    div.appendTo("body")

  getPanel = (idx) ->
    return boards.panels[idx]

  getSurround = (idx) ->
    w = parseInt(boards.x)
    h = parseInt(boards.y)

    top = idx-w
    left = idx-1
    right = idx+1
    bottom = idx+w

    if top < 0
      top = null
      topl = null
      topr = null
    else
      topl = top-1
      topr = top+1

    if bottom >= boards.size
        bottom = null
        bottoml = null
        bottomr = null
    else
        bottoml = bottom-1
        bottomr = bottom+1

    if idx == 0 or (idx > 0 and idx%w == 0)
      left = null
      topl = null
      bottoml = null
    if right%w == 0
      right = null
      topr = null
      bottomr = null

    surround =
      top: top
      topl: topl
      topr: topr
      left: left
      right: right
      bottom: bottom
      bottoml: bottoml
      bottomr: bottomr

    for i of surround
      if surround[i] == null
        delete surround[i]

    return surround

$(document).ready ->
  mine = new Minesweeper()

  $("#restart").click ->
      mine.initialize()

  $(".menu span.button").each ->
    $(this).click () ->
      type = $(this).attr("id")
      mine.gameType = type
      mine.initialize()

