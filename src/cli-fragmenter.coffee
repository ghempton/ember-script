sepExpr = (name) ->
  RegExp "#\\s\\(#{name}\\)\\s*", 'i'

separator = (code) ->
  code.match sepExpr('ember')

module.exports = (code) ->
  fragments =
    js: ''
    ember: ''

  matches = separator(code)

  unless matches
    # console.log 'no fragments detected!'
    fragments.ember = code
    return fragments

  firstMatch = matches[0]
  seperatorIndex = code.indexOf firstMatch
  emberStartIndex = seperatorIndex + firstMatch.length
  fragments.js    = code.slice 0, seperatorIndex
  fragments.ember = code.slice emberStartIndex
  fragments