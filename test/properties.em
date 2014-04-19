suite 'Properties', ->

  setup ->
    @isVolatile = (prop) ->
      Ember.meta(prop).source._cacheable == false
    @hasDependentKeys = (prop, deps) ->
      Ember.A(deps).every (key) ->
        Ember.meta(prop).source._dependentKeys.contains(key)

  suite 'Dependency Inference', ->

    test 'should create property', ->
      cp = ~> 1
      ok cp instanceof Ember.ComputedProperty

    test 'should infer simple dependency', ->
      cp = ~> @y.z
      ok @hasDependentKeys(cp, ['y.z'])

    test 'should infer simple dependency from soaked', ->
      cp = ~> @y?.z
      ok @hasDependentKeys(cp, ['y.z'])

    test 'should infer multiple dependencies', ->
      cp = ~> @x + @y + @z.name
      ok @hasDependentKeys(cp, ['x', 'y', 'z.name'])

    test 'should infer enumerable dependency', ->
      cp = ~> @x.y.forEach(->)
      ok @hasDependentKeys(cp, ['x.y.@each'])

    test 'should infer enumerable dependency from soaked operation', ->
      cp = ~> @x?.forEach(->)
      ok @hasDependentKeys(cp, ['x.@each'])

    test 'should not add function name to dependent keys', ->
      cp = ~> @content.someMethod()
      ok @hasDependentKeys(cp, ['content'])

    test 'should not create duplicate keys', ->
      cp = ~> @x + @x
      ok @hasDependentKeys(cp, ['x'])

    test 'should concat property dependencies from variables in scope', ->
      cp = ~>
        x = @x
        y = x.y
        z = y.z
      ok @hasDependentKeys(cp, ['x.y.z'])

    test 'should concat property dependencies in complex scope', ->
      cp = ~>
        if @content
          x = @x
          y = x.y
          z = y.z
        else
          x = @s
        x.q
      ok @hasDependentKeys(cp, ['content', 'x.y.z.q', 's.q'])

    test 'should create dependencies for arguments to function', ->
      func = ->
      cp = ~>
        func(@content, @otherContent, @content.subProperty, @x.forEach(->))
      ok @hasDependentKeys(cp, ['content', 'otherContent', 'content.subProperty', 'x.@each'])

    test 'should create dependencies for local bound function', ->
      cp = ~>
        [1,2,3,4,5].find (num) ->
          @content == num
      ok @hasDependentKeys(cp, ['content'])

    test 'should not create dependency for constructor', ->
      cp = ~>
        @x.constructor.toString()
      ok @hasDependentKeys(cp, ['x'])

  suite 'Annotations', ->

    test 'computed annotation should create computed property', ->
      obj =
        +computed
        prop: -> @name
      ok obj['prop'] instanceof Ember.ComputedProperty

    test 'computed annotation should allow for explicit dependencies', ->
      obj =
        +computed firstName, lastName
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
        +volatile firstName, lastName
        prop: -> @firstName @lastName
      ok @hasDependentKeys(obj['prop'], ['firstName', 'lastName'])
      ok @isVolatile(obj['prop'])

    test 'annotations parameters should accept dot-separated property paths', ->
      obj =
        +computed name.first
        prop: -> @name.first
      ok @hasDependentKeys(obj['prop'], ['name.first'])

    test 'annotations parameters should accept @each', ->
      obj =
        +computed arr.@each
        prop: -> @arr
      ok @hasDependentKeys(obj['prop'], ['arr.@each'])

    test 'annotations parameters should accept []', ->
      obj =
        +computed arr.[]
        prop: -> @arr
      ok @hasDependentKeys(obj['prop'], ['arr.[]'])


  suite 'Native Member Property Accessor', ->

    test 'basic property access', ->
      obj = {x: 5}
      equal obj*.x, 5

    test 'should return raw computed property', ->
      obj = Ember.Object.createWithMixins
        +computed
        prop: -> 5
      equal obj.prop, 5
      equal obj*.prop, undefined
