fragmenter = (options) ->
  # by default starts with js
    
  anyFragExpr = /#\s\((ember|em|coffee|cs|ecma|js|live|ls)\)\s*/

  createFragment = (lang, code) ->
    {type: lang, code: code}

  fragmentStack = [options.lang or 'coffee']

  return {
    fragments: []
    
    fragmentize: (code) ->
      nextFragMatch = code.match anyFragExpr
      unless nextFragMatch
        return @fragments.push(createFragment fragmentStack.shift(), code)

      # get text matched (separator: start of next fragment)
      matchTxt = nextFragMatch[0]

      # get index of separator
      index = code.indexOf matchTxt

      # get current fragment until next fragment starts
      curFragment = code.slice(0, index)
      @fragments.push(createFragment fragmentStack.shift(), curFragment)
      # add lang for next iteration
      fragmentStack.push nextFragMatch[1]

      # advance code cursor until start of next fragment
      @fragmentize code.slice(index + matchTxt.length)
    }

compilerAliases =
  cs: 'coffee'
  em: 'ember'
  ecma: 'js'
  ls: 'live'

resolveCompilerAlias = (alias) ->
  compilerAliases[alias] or alias

commentTransform = (compiled, type) ->
  compileComment = "\n// compile fragment: #{type}\n"
  compileComment.concat compiled

createIterator = (compilers, options) ->

  transform = options.transformer or commentTransform

  (fragment, cb) ->
    type = resolveCompilerAlias fragment.type
    code = fragment.code

    compiled = transform compilers[type](code), type
    
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

concatAll = (code, compilers, cb, options) ->
  options = options or {}

  fragger = fragmenter options
  fragger.fragmentize code
  # console.log fragger

  async.concat(fragger.fragments, createIterator(compilers, options), (err, results) ->
    return next(err)  if (err)
    cb results.join('\n')
  )

module.exports = concatAll