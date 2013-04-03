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
sudo npm install -g 'git://github.com/ghempton/ember-script.git#HEAD'
ember-script --help
```

## Development

```
make -j build test
```
