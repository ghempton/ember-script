### Script fragmentation

The fragmenter is currently used to enable prepending of javascript before ember-script generated code (resolves issue #42). The fragmenter has been designed to be easy to customize and also allows appending code using the same pattern if necessary. You could even extend it to compile each code fragment separately and merge them all at the end... 

### CoffeeScript/LiveScript compilation

See `process-input.coffee` for examples of usage checkout the Coffeescript npm site/repo

To compile *CoffeeScript* to bare *JavaScript* simply do:

`CoffeeScript.compile source, { bare: true }`

Similar for LiveScript (since a fork of coffeescript):

```coffeescript
# https://github.com/gkz/LiveScript/blob/master/src/index.ls#L20
# Compiles a string of LiveScript code to JavaScript.
compile: (code, options = {}) ->    
```

`LiveScript.compile code, { bare: true }`

This could be used for a multi-fragment solution:

### Multi-script fragmentation

Allow for a mix of scripting languages in one file:

`# (ember)` emberscript fragment starts
`# (js)` javascript
`# (coffee)` coffeescript
`# (live)` livescript

The infrastructure for this has already been enabled with `src/multi-compiler.coffee`

Furthermore, we should be able to compile bare EmberScript via:

```coffeescript
# as found in register.coffee

# some text input
input = fs.readFileSync filename, 'utf8'

csAst = EmberScript.parse input, raw: yes, literate: yes
jsAst = EmberScript.compile csAst
js = EmberScript.js jsAst
```

Some sample code: (perhaps not so suitable for Editors, unless they respect this convention in the near future!)

```
var a = js;

# (coffee)
y = coffee with a

# (ember)
class Post
  trimmedPosts: ~>
    @content?.slice(0, 3)

# (live)
x = milk and y
```

Testing:

`$ bin/ember-script -j --input sandbox/multicompile-code.em`

For the multi-compiler, we could do sth like:

```coffeescript
EmberScript  = require './module'
CoffeeScript = require './module'

LiveScript = require('livescript')

EmberScript.compileCode = (input, options) ->
  csAst = EmberScript.parse input, 
  jsAst = EmberScript.compile csAst
  EmberScript.js jsAst

compilers =
  js: (source) ->
    source

  coffee: (source) ->
    CoffeeScript.compile source, { bare: true }

  live: (source) ->
    LivesScript.compile source, { bare: true }

  ember: (source) ->
    EmberScript.compileCode, {raw: yes, literate: yes}
}

# emit the code to a file or stdout
# depending on options

createCodeEmitter = (options)
  (code) ->
    if options.output    
      fs.writeFile options.output, code, (err) ->
        throw err if err?
    else
      process.stdout.write code


multiCompile = require './multi-compiler'

multiCompile code, compilers, createCodeEmitter(options)
```

Sweet :)
