suite 'Properties', ->

  setup ->
    @isVolatile = (prop) ->
      Ember.meta(prop).source._cacheable == false
    @hasDependentKeys = (prop, deps) ->
      Ember.A(deps).every (key) ->
        Ember.meta(prop).source._dependentKeys.contains(key)

  suite 'Squiggly Operator', ->

    test 'should create property', ->
      cp = ~> 1
      ok cp instanceof Ember.ComputedProperty

    test 'should infer simple dependency', ->
      cp = ~> @y.z
      ok @hasDependentKeys(cp, ['y.z'])

    test 'should infer multiple dependencies', ->
      cp = ~> @x + @y + @z.name
      ok @hasDependentKeys(cp, ['x', 'y', 'z.name'])

  suite 'Annotations', ->

    test 'computed annotation should create computed property', ->
      obj =
        +computed
        prop: -> @name
      ok obj['prop'] instanceof Ember.ComputedProperty

    test 'computed annotation should allow for explicit dependencies', ->
      obj =
        +computed firstName lastName
        prop: -> @firstName @lastName
      ok @hasDependentKeys(obj['prop'], ['firstName', 'lastName'])

    test 'volatile annotation should create volatile computed property', ->
      obj =
        +volatile
        prop: -> @name
      ok obj['prop'] instanceof Ember.ComputedProperty
      ok @isVolatile(obj['prop'])

    test 'volatile annotation should allow for explicit dependencies', ->
      obj =
        +volatile firstName lastName
        prop: -> @firstName @lastName
      ok @hasDependentKeys(obj['prop'], ['firstName', 'lastName'])
      ok @isVolatile(obj['prop'])
