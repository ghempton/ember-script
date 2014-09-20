[![Build Status](https://travis-ci.org/ghempton/ember-script.png?branch=master)](https://travis-ci.org/ghempton/ember-script)

# EmberScript

EmberScript is a CoffeeScript-derived language which takes advantage of the [Ember.js](http://emberjs.com) runtime. Ember constructs such as Inheritance, Mixins, Bindings, Observers, etc. are all first-class citizens within EmberScript.

## Examples

```coffeescript
class PostsController extends Ember.ArrayController
  trimmedPosts: ~>
    @content.slice(0, 3)
```

compiles to:

```javascript
var PostsController;
var get$ = Ember.get;
PostsController = Ember.ArrayController.extend({
  trimmedPosts: Ember.computed(function () {
    return get$(this, 'content').slice(0, 3);
  }).property('content.@each')
});
```

For a more comprehensive list of live examples, check out the main [EmberScript website](http://emberscript.com).

## Is this ready to use?

For the most part, but use at your own risk. See the [todo](https://github.com/ghempton/ember-script/blob/master/TODO.txt) list for details. It is recommended to use EmberScript side by side with javascript and/or coffeescript.

## Installation

### Ruby on Rails

If you are using Rails as your backend, simply add the following to your Gemfile:

```
gem 'ember_script-rails'
```

All assets ending in `.em` will be compiled by EmberScript.

### Npm

```
sudo npm install -g ghempton/ember-script
ember-script --help
```

## Development

```
make -j build test
```

## Script fragments and Multi compilation

This branch support compilation of script fragments (multi compilation).
It was added in order to better support environments where you need more control of the compilation, such
as with ember-cli and ES6 modules.

```coffeescript
var a = "js";

# (coffee)

y = "coffee with a"

# (ember)

class Post
  trimmedPosts: ~>
    @content?.slice(0, 3)

# (live)

x = "milk and y"
```

Valid aliases are: 

- coffeescript: 
  `cs`,   `coffee`
- javascript:   
  `js`,   `ecma`
- livescript:   
  `ls`,   `live`
- emberscript:  
  `em`, `ember`

The first block is (by default) assumed to be *coffeescript* (unless you have a script identifier comment as the first line of code). 

### Customization

For your own customizations, go to the end of `cli-multi-compile.coffee` and change `compilers` or `codeEmitter`. You can also send an extra `mcOptions` object as the last argument. This object can 
take a `transformer` function (f.ex to prepend each compiled fragment with a custom comment) and a `lang` (string) argument to override `coffeescript` as the default/first fragment script language.

```coffeescript
multiCompile = require './multi-compiler'

module.exports = (code, options) ->
  mcOptions = {
    lang: 'coffee'
  }
  codeEmitter = options.codeEmitter || createCodeEmitter(options)
  multiCompile code, compilers, codeEmitter, mcOptions
```





