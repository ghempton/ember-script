suite 'Classes', ->

  suite 'Class Definition', ->

    test 'classes are instances of Ember.Object', ->
      class Person
      p = new Person
      ok p instanceof Ember.Object

    test 'classes can extend other classes', ->
      class Person
      class Andrew extends Person
      andrew = new Andrew
      ok andrew instanceof Ember.Object
      ok andrew instanceof Person

    test 'classes can extend classes that are member accesses', ->
      class App
      class App.Controller
      class MyController extends App.Controller
      ok App.Controller.detect(MyController) 

    test 'classes can be defined with mixins', ->
      mixin DesignerMixin
      class Person
      class Andrew extends Person with DesignerMixin
      andrew = new Andrew
      ok DesignerMixin.detect(andrew)

    test 'mixins can be member expressions', ->
      X = {}
      mixin X.Person
      class Andrew with X.Person
      andrew = Andrew.create()
      ok X.Person.detect(andrew)

    test 'classes can be defined with multiple mixins', ->
      mixin A
      mixin B
      class AB with A, B
      ab = AB.create()
      ok A.detect(ab)
      ok B.detect(ab)

    test 'mixins can be defined with mixins', ->
      mixin A
      mixin B with A
      mixin C
      mixin D with A, B
      class ABCD with C, D
      abcd = ABCD.create()
      ok A.detect(abcd)
      ok B.detect(abcd)
      ok C.detect(abcd)
      ok D.detect(abcd)
