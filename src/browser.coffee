module.exports = EmberScript = require './module'

global.EmberScript = EmberScript

# Use standard JavaScript `eval` to eval code.
EmberScript.eval = (code, options = {}) ->
  options.bare ?= on
  options.optimise ?= on
  eval EmberScript.em2js code, options

# Running code does not provide access to this scope.
EmberScript.run = (code, options = {}) ->
  options.bare = on
  options.optimise ?= on
  do Function EmberScript.em2js code, options

# Load a remote script from the current domain via XHR.
EmberScript.load = (url, callback) ->
  xhr = if window.ActiveXObject
    new window.ActiveXObject 'Microsoft.XMLHTTP'
  else
    new XMLHttpRequest
  xhr.open 'GET', url, true
  xhr.overrideMimeType 'text/plain' if 'overrideMimeType' of xhr
  xhr.onreadystatechange = ->
    return unless xhr.readyState is xhr.DONE
    if xhr.status in [0, 200]
      EmberScript.run xhr.responseText
    else
      throw new Error "Could not load #{url}"
    do callback if callback
  xhr.send null

# Activate EmberScript in the browser by having it compile and evaluate
# all script tags with a content-type of `text/emberscript`.
# This happens on page load.
runScripts = ->
  scripts = document.getElementsByTagName 'script'
  coffees = (s for s in scripts when s.type is 'text/emberscript')
  index = 0
  do execute = ->
    return unless script = coffees[index++]
    if script.src
      EmberScript.load script.src, execute
    else
      EmberScript.run script.innerHTML
      do execute
  null

# Listen for window load, both in browsers and in IE.
if addEventListener?
  addEventListener 'DOMContentLoaded', runScripts, no
else if attachEvent?
  attachEvent 'onload', runScripts
