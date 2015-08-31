
cmp = (a, b) ->
  pointsA = getPoints a
  pointsB = getPoints b

  if pointsA isnt pointsB
    return pointsB - pointsA

  if a < b
    return -1
  if a == b
    return 0
  if a > b
    return 1

getPoints = (str) ->
  if !str
    return 1

  firstChar = str['var '.length]
  if firstChar.toLowerCase() is firstChar
    return 0

  if firstChar.toUpperCase() is firstChar
    return 2

  return 3


module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', "atom-insert-require:insert", => @insert()

  insert: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.getActivePaneItem()

    bufferRange = editor.getSelectedBufferRange()

    requireName = editor.getLastSelection().getText()
    if !requireName
        range = editor.getSelectedBufferRange()
        editor.selectWordsContainingCursors()
        requireName = editor.getLastSelection().getText()
        editor.setSelectedBufferRange(range)

    lines = editor.getText().split '\n'

    requireRegex = /^var [a-zA-Z0-9]+ = require/
    startRequire = -1
    endRequire = lines.length
    for line, i in lines
      if startRequire is -1
        if line.match requireRegex
          startRequire = i

      if startRequire isnt -1
        if line and not line.match requireRegex
          endRequire = i - 1
          break

    if startRequire is -1
      startRequire = 0
      endRequire = 0

    requires = lines.slice startRequire, endRequire
    toAdd = "var #{requireName} = require('#{requireName}');"
    if requires.indexOf(toAdd) is -1
      requires.push toAdd
    requires.sort cmp

    editor.setTextInBufferRange(
      [[startRequire, 0], [endRequire, 0]],
      (requires.join '\n') + '\n'
    )
