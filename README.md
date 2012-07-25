# Ember Script

Ember Script is coffee-derived inspired language which takes advantage of the [Ember.js](http://emberjs.com) runtime. Ember constructs such as Inheritance, Mixins, Bindings, Observers, etc. are all first-class citizens within Ember Script.

## Examples

### Object Instantiation

```coffeescript
animal = new Animal()
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

class Bird extends Animal
  include CanFly

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

### Properties, Bindings, and Observers

Because Ember Script is a compiled language, property dependencies can be computed at compile time.

```coffeescript
class Person

  [Computed("firstName, lastName")]
  name: -> "#{@firstName} #{@lastName}"

  [Computed]
  [Infer]
  capitalizedFirstName: -> @firstName.toUpperCase()

  [Observes]
  [Infer]
  nameChanged: console.log("new name: #{@name}")

  [Binding("firstName", "App.currentUser.firstName")]
```

Compiles to:

```javascript
Person = Ember.Object.extend({

  name: Ember.computed(function() {
    return Ember.get(this, 'firstName') + ' ' + Ember.get(this, 'lastName');
  }).property("firstName", "lastName")

  capitalizedFirstName: Ember.computed(function() {
    return Ember.get(this, 'firstName').toUpperCase();
  }).property('firstName');

  nameChanged: Ember.observes(function() {
    return console.log("new name: " + Ember.get(this, 'name');
  }, 'name');

  firstNameBinding: 'App.currentUser.firstName'

});
```

## Accessing Properties

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

Compiles to:

```javascript
Ember.get(person, 'firstName');
Ember.get(Ember.get(person, 'address'), 'city');
Ember.get(person, 'address.city');
person && Ember.getPath(person, 'address.city');

Ember.set(person, 'firstName', "Wes");
Ember.set(person, 'address.city', "San Diego");

Ember.get(Ember.get(this, 'person'), 'firstName');
Ember.set(Ember.get(this, 'person'), 'firstName', "Andrew");

person.firstName
person.firstName = "Manuel"
```




