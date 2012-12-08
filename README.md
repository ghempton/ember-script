# Ember Script

Ember Script is coffee-derived inspired language which takes advantage of the [Ember.js](http://emberjs.com) runtime. Ember constructs such as Inheritance, Mixins, Bindings, Observers, etc. are all first-class citizens within Ember Script.

## Is this ready to use?

No, it is still being developed. See the [todo](https://github.com/ghempton/ember-script/blob/master/TODO.txt) list for details.

## Installation

Being as EmberScript is still in early development, it is best to install via npm from source. After installing [Node.js](http://nodejs.org/), run the following commands:

```
git clone git@github.com:ghempton/ember-script.git
cd ember-script
npm install
make
bin/coffee --help
```

For use with ember-script-ruby or ember-script-rails, make the `ember-script` command available system wide:

```
npm install . -g
```

## Examples

### Object Model

```coffeescript
animal = new Animal
```

Compiles to:

```javascript
animal = Animal.create();
```

### Inheritance and Mixins

```coffeescript
mixin CanFly
  fly: -> console.log('flying')

class Animal

class Bird extends Animal with CanFly

  fly: ->
    super()
    console.log('flap wings')
```

Compiles to:

```javascript
CanFly = Ember.Mixin.create({
  fly: function() {
    return console.log('flying');
  }
});

Animal = Ember.Object.extend();

Bird = Animal.extend(CanFly, {
  fly: function() {
    _super();
    return console.log('flap wings');
  }
});
```

### Properties: Getters and Setters

```coffeescript
class Person
  get name: -> @_name
  set name: (value) -> @_name = value

  get firstName: @name.split(' ')[0]

  lastName: ~> @name.split(' ')[1]
```

Compiles to:

```javascript
var get = Ember.get, set = Ember.set;

Person = Ember.Object.extend({

  name: Ember.computed(function(value) {
    if (arguments.length === 2) {
      set(this, '_name', value);
      return value;
    } else {
      return Ember.get(this, '_name');
    }
  }),

  firstName: Ember.computed(function() {
    return get(this, 'name').split(' ')[0];
  }),

  lastName: Ember.computed(function() {
    return get(this, 'name').split(' ')[1];
  }).property('name')

});

```

### Annotations: Dependencies, Observers, and More

```coffeescript
class Person

  +computed firstName, lastName
  initials: -> "#{@firstName.split('')[0], @lastName.split('')[0]}"

  +observes name
  nameChanged: -> console.log("new name: #{@name}")

  +volatile
  favoriteNumber: -> Math.round(Math.random() * 10)

```

Compiles to:

```javascript
Person = Ember.Object.extend({

  initials: Ember.computed(function() {
    return get(this, 'firstName').split('')[0] + " " + get(this, 'lastName').split('')[0];
  }).property("firstName", "lastName"),

  nameChanged: Ember.observes(function() {
    return console.log("new name: " + get(this, 'name'));
  }, 'name'),

  favoriteNumber: Ember.computed(function() {
    return Math.round(Math.random() * 10);
  }).volatile()

});
```

### Dependency Inferrence

Because Ember Script is a compiled language, property dependencies can be computed at compile time. In fact, there is a special operator to declare a computed property with it's dependencies inferred, the `~>` operator. The `initials` property above could be rewritten more simply as:

```coffeescript
  initials: ~> "#{@firstName.split('')[0], @lastName.split('')[0]}"
```

The dependency on the `firstName` and `lastName` properties will be determined at compile time.

### Accessors

In general, normal dot-syntax property access is delegated to Ember's get and set methods. To use javascript's native property access operator, use Ember Script's *. operator:

```coffeescript
person.firstName
person.address.city
person.address?.city
person?.address?.city

person.firstName = "Wes"
person.address.city = "San Diego"

@person.firstName
@person.firstName = "Andrew"

person*.firstName
person*.firstName = "Manuel"
```

Roughly compiles to:

```javascript
var get = Ember.get, set = Ember.set;

get(person, 'firstName');
get(get(person, 'address'), 'city');
get(person, 'address.city');
person && get(person, 'address.city');

set(person, 'firstName', "Wes");
set(person, 'address.city', "San Diego");

get(get(this, 'person'), 'firstName');
set(get(this, 'person'), 'firstName', "Andrew");

person.firstName
person.firstName = "Manuel"
```

## Development

```
make -j build test
```