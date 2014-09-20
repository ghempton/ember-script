anyFragExpr = /#\s\((ember|em|coffee|cs|ecma|js|live|ls)\)\s*/

fragments = []

createFragment = (lang, code) ->
  {type: lang, code: code}

# by default starts with js
fragmentHistory = ['js'];

fragmentize = (code) ->
  nextFragMatch = code.match anyFragExpr
  unless nextFragMatch
    return fragments.push(createFragment fragmentHistory.shift(), code)

  # get text matched (separator: start of next fragment)
  matchTxt = nextFragMatch[0]

  # get index of separator
  index = code.indexOf matchTxt

  # get current fragment until next fragment starts
  curFragment = code.slice(0, index)
  fragments.push(createFragment fragmentHistory.shift(), curFragment)
  # add lang for next iteration
  fragmentHistory.push nextFragMatch[1]

  # advance code cursor until start of next fragment
  fragmentize code.slice(index + matchTxt.length)


compilerAliases =
  cs: 'coffee'
  em: 'ember'
  ecma: 'js'
  ls: 'live'

resolveCompilerAlias = (alias) ->
  compilerAliases[alias] || alias

createIterator = (compilers) ->
  (fragment, cb) ->
    type = resolveCompilerAlias fragment.type
    code = fragment.code

    compiled = compilers[type](code)

    cb null, compiled

async = require 'async'

# Arguments: 
# @code to compile in parallel

# @compilerss a compiler object where each key is one of js, coffee, live, ember:  

# Example:
# {coffee: function(codeToCompile) {}, ember: ...}

# callback to receive the compiled code when done

# Example:
# showCompiledCode = (compiledCode) ->
#   console.log return compiledCode

concatAll = (code, compilers, cb) ->
  fragmentize code
  async.concat(fragments, createIterator(compilers), (err, results) ->
    return next(err)  if (err)
    cb results.join('\n')
  )

module.exports = concatAll