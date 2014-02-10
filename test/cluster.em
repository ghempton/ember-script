child_process = require 'child_process'
path = require 'path'

semver = require 'semver'

binary = path.resolve 'bin', 'ember-script'

if semver.satisfies process.version, '>= 0.10.0'
  test "jashkenas/coffee-script#2737: cluster module can spawn coffee workers", (done) ->
    (child_process.spawn binary, ['test/cluster/cluster.em']).on 'close', (code) ->
      eq 0, code
      do done
      return

  test "jashkenas/coffee-script#2737: cluster module can spawn litcoffee workers", (done) ->
    (child_process.spawn binary, ['test/cluster/cluster.litem']).on 'close', (code) ->
      eq 0, code
      do done
      return
