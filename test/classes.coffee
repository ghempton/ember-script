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