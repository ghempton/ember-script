obj = Ember.Object.create
  +computed
  prop: -> 5
console.log obj.prop
equal obj.prop, 5
ok obj*.prop instanceof Ember.ComputedProperty