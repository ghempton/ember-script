# start processing options

path = require 'path'

$0 = if process.argv[0] is 'node' then process.argv[1] else process.argv[0]
$0 = path.basename $0

console.log "
Usage: (OPT is interpreted by #{$0}, ARG is passed to FILE)

  #{$0} OPT* -{p,c,j,f} OPT*
    example: #{$0} --js --no-optimise <input.coffee >output.js
  #{$0} [-e] FILE {OPT,ARG}* [-- ARG*]
    example: #{$0} myfile.coffee arg0 arg1
  #{$0} OPT* [--repl] OPT*
    example: #{$0}

-b, --bare              omit the top-level function wrapper
-c, --compile           output a JSON-serialised AST representation of the output
-e, --eval              evaluate compiled JavaScript
-f, --cscodegen         output cscodegen-generated CoffeeScript code
-i, --input FILE        file to be used as input instead of STDIN
-I, --require FILE      require a library before a script is executed
-j, --js                generate JavaScript output
-l, --literate          treat the input as literate CoffeeScript code
-m, --minify            run compiled javascript output through a JS minifier
-o, --output FILE       file to be used as output instead of STDOUT
-p, --parse             output a JSON-serialised AST representation of the input
-v, --version           display the version number
-w, --watch FILE        watch the given file/directory for changes
--cli INPUT             pass a string from the command line as input
--debug                 output intermediate representations on stderr for debug
--help                  display this help message
--nodejs OPTS           pass options through to the node binary
--optimise              enable optimisations (default: on)
--raw                   preserve source position and raw parse information
--repl                  run an interactive CoffeeScript REPL
--source-map            generate source map
--source-map-file FILE  file used as output for source map when using --js

Unless given --input or --cli flags, `#{$0}` will operate on stdin/stdout.
When none of --{parse,compile,js,source-map,eval,cscodegen,repl} are given,
  If positional arguments were given
    * --eval is implied
    * the first positional argument is used as an input filename
    * additional positional arguments are passed as arguments to the script
  Else --repl is implied
"