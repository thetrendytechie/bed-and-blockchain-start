App = {
  web3Provider: null,
  contracts: {},
  account: 0x0,

  init: function() {
    // Load property details
    $.getJSON('../property.json', function(data) {
      var propertiesRow = $('#propertiesRow');
      var propertyTemplate = $('#propertyTemplate');

      for (i = 0; i < data.length; i ++) {
        //fill template with data from property.json
      }
    });

    App.displayAccountInfo();

    return App.initWeb3();
  },

  displayAccountInfo: function() {
    //insert code to display account info in header
  },

  initWeb3: function() {
    //insert code to detect injected web3 instance or initialize a new one using ganache
  },

  initContract: function() {
    //insert code to initialize contract
  },

  bindEvents: function() {
    //insert code to bind events to UI
  },

  markBooked: function(bookings, account) {
    //insert code to update UI when a property is booked
  },

  handleBook: function(event) {
    //insert code to handle booking event
  }
};


$(function() {
  $(window).load(function() {
    App.init();
  });
});
