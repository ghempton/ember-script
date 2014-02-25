child_process = require 'child_process'

suite 'Command line execution', ->
  test "--eval -i", (done) ->
    child_process.exec 'bin/ember-script --eval -i test/cli-eval-errors-files/1.em', (error, stdout, stderr) ->
      # Executed module is require.main
      # Module path is relative to the file
      # Can include another CS module
      # Other module is not requires.main
      eq stdout, "1 is main true\n0 is main false\n"

      ok stderr.indexOf("cli-eval-errors-files/0.em:3:26, <js>:6:9)") > 0
      ok stderr.indexOf("cli-eval-errors-files/1.em <js>:7:9)") > 0

      done()

  test "--eval --cli", (done) ->
    child_process.exec 'bin/ember-script --eval --cli "require \'./test/cli-eval-errors-files/1.em\'"', (error, stdout, stderr) ->
      eq stdout, "1 is main false\n0 is main false\n"
      done()
