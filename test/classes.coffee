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

    test 'classes can be defined with mixins', ->
      DesignerMixin = Ember.Mixin.create()

      class Person
      class Andrew extends Person with DesignerMixin

      andrew = new Andrew()

      ok DesignerMixin.detect(andrew)