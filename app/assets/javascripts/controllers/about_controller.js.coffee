App.AboutController = Ember.Controller.extend
  needs: ['application']
  currentUserBinding: Ember.Binding.oneWay('controllers.application.currentUser')

App.AboutIntroController = Ember.Controller.extend
  needs: ['application']

App.AboutHowItWorksController = Ember.Controller.extend
  needs: ['application']