suite 'Properties', ->

  setup ->
    @hasDependentKeys = (prop, deps) ->
      Ember.A(deps).every (key) ->
        Ember.meta(prop).source._dependentKeys.contains(key)

  suite 'Squiggly Operator', ->

    test 'should create property', ->
      x = ~> 1
      ok x instanceof Ember.ComputedProperty

    test 'should infer simple dependency', ->
      x = ~> @y.z
      ok @hasDependentKeys(x, ['y.z'])
