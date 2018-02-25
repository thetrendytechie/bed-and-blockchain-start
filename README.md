# bed-and-blockchain-start
Starting project for Bed and Blockchain dapp demo - code stubs for solidity and js. The fully built version of this tutorial is available at: [https://github.com/thetrendytechie/bed-and-blockchain](https://github.com/thetrendytechie/bed-and-blockchain)

## Tools Required:

Before you clone this repo, ensure you have the following tools installed:

* Solidity
* Ganache
* Truffle
* Node Package Manager
* Node.js
* MetaMask

## Running the dapp:

Upon cloning the repo, cd into the directory using your terminal/command line and run:
	
	npm install

This will install the required dependencies.

###1. Write the Booking.sol Smart Contract

Under the /contracts folder, create a new file named Booking.sol. This will be our booking smart contract. Write the following code:

	pragma solidity ^0.4.19;
	
	contract Booking {
	  address[8] public bookings;
	  uint256 revenue;
	  uint256 capacity;
	  uint256 rate;
	  string name;
	  string propertyType;
	  string location;
	  address booker;
	  address receiveValue = 0x0;
	
	  function Booking() public{
	    revenue = 0;
	  }
	
	  //book a property by adding the address of the booker to the bookings array
	  function book(uint propertyId) public returns(uint){
	    require(propertyId >= 0 && propertyId <= 7);
	    booker = msg.sender;
	    bookings[propertyId] = booker;
	
	    return propertyId;
	  }
	
	  //retrieve booking status of all properties
	  function getBookings() public view returns (address[8]) {
	    return bookings;
	  }
	
	  function getProperty() public view returns (address _booker, string _name, string _propertyType, uint256 _capacity, string _location, uint256 _rate) {
	      return(booker, name, propertyType, capacity, location, rate);
		}
	
	}


###2. Write Migration

In the /migrations folder, create a new file called: 

	2_deploy_contracts.js
	
In this file, write the following code to migrate our Booking contract to the network:

	var Booking = artifacts.require("./Booking.sol");

	module.exports = function(deployer) {
	  deployer.deploy(Booking);
	};


###3. Display Property Data in UI

In /src/app.js, complete the init function as follows. This code loads the property details from property.json into the html page.
	
	init: function() {
	    // Load property details
	    $.getJSON('../property.json', function(data) {
	      var propertiesRow = $('#propertiesRow');
	      var propertyTemplate = $('#propertyTemplate');
	
	      for (i = 0; i < data.length; i ++) {
	        propertyTemplate.find('.panel-title').text(data[i].name);
	        propertyTemplate.find('img').attr('src', data[i].picture);
	        propertyTemplate.find('.property-type').text(data[i].type);
	        propertyTemplate.find('.property-capacity').text(data[i].sleeps);
	        propertyTemplate.find('.property-location').text(data[i].location);
	        propertyTemplate.find('.btn-book').attr('data-id', data[i].id);
	        propertyTemplate.find('.property-rate').text(data[i].rate);
	        //set the rate as an attribute of the booking button as well:
	        propertyTemplate.find('.btn-book').attr('data-value', data[i].rate);
	
	
	        propertiesRow.append(propertyTemplate.html());
	      }
	    });
	
	    App.displayAccountInfo();
	
	    return App.initWeb3();
	  },

Now, when you run the dapp, you should be able to see a UI populated with property data. To migrate your contract to the dapp, execute the following command in your terminal:

	truffle migrate --compile-all --reset --network development
	
This will compile the files and deploy the contract to the network.

Now you are ready to launch the dapp. This dapp uses Lite Server to run in the browser. Run the following:

	 npm run dev 
	 
This should start lite-server and open your dapp in a browser. Note that you must use Chrome with MetaMask or another browser wallet to be able to interact with the blockchain through this dapp.

###4. Display Account Address and Balance in UI

Next, we want to display the address of the current account, as well as its current balance, in the header of the interface. Complete the displayAccountInfo function as follows: 

	//Get current account info and display in header
	  displayAccountInfo: function() {
	    web3.eth.getCoinbase(function(err, account) {
	      if(err === null) {
	        App.account = account;
	        $('#account').text("Current Account: " + account);
	        web3.eth.getBalance(account, function(err, balance) {
	          if(err === null) {
	            $('#accountBalance').text("Current Balance: " + web3.fromWei(balance, "ether") + " ETH");
	          }
	        })
	      }
	    });
	  },
	  
To test this functionality, switch back to Chrome. You do not have to redeploy the contract using truffle at this time because we have not changed the smart contract, and you do not have to restart lite-server because it picks up the changes to app.js dynamically. 

###5. Initialize Web3

	initWeb3: function() {
    //is there an injected web3 instance?
    if(typeof web3 !== 'undefined'){
      App.web3Provider = web3.currentProvider;
    } else {
      //if no injected web3 instance is detected, use Ganache
      App.web3Provider = new Web3.providers.HttpProvider("http://localhost:7545");
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },


###6. Initialize Contract

  	initContract: function() {
    $.getJSON('Booking.json', function(data){
      //Get the necessary contract artifact file and instantiate it
      var BookingArtifact = data;
      App.contracts.Booking = TruffleContract(BookingArtifact);

      //Set the provider for our contract
      App.contracts.Booking.setProvider(App.web3Provider);

      //Identify the properties that have already been booked
      return App.markBooked();

    });

    return App.bindEvents();
  },


###7. Implement Booking Functionality

When the user clicks a "BOOK" button, we want their address information to be logged in the booking array at the index of the property they intend to book. 

In order to implement this, we will first need to bind the click event to the buttons. To do so, complete the bindEvents function:

	bindEvents: function() {
    	$(document).on('click', '.btn-book', App.handleBook);
    },

Then we will need to make a call to the smart contract's book() function, passing in some information. Complete the handleBook function as follows:

	  handleBook: function(event) {
	    event.preventDefault();
	
	    var propertyId = parseInt($(event.target).data('id'));
	    var bookingInstance;
	
	    web3.eth.getAccounts(function(error, accounts){
	      if(error){
	        console.log(error);
	      }
	      App.contracts.Booking.deployed().then(function(instance){
	        bookingInstance = instance;
	        
	        //Execute book() - note, since it is a transaction we must send the from address and the value
	        return bookingInstance.book(propertyId, {from: App.account, gas: 500000});
	      }).then(function(result){
	        return App.markBooked();
	      }).catch(function(err){
	        console.log(err.message);
	      });
	    });
	  }

We also want to make a change to the UI to reflect the property's status. If the current user (logged in through MetaMask) is the same as the user who booked a property, we will turn that property's button green and change its text to "BOOKED". If the property was booked by a different user, we turn it grey with the text "UNAVAILABLE". Here is the code to do this, in the markBooked function:

	  markBooked: function(bookings, account) {
	    var bookingInstance;
	    App.contracts.Booking.deployed().then(function(instance){
	      bookingInstance = instance;
	      return bookingInstance.getBookings.call();
	    }).then(function(bookings){
	      for(i = 0; i < bookings.length; i++){
	        if(bookings[i] == App.account){
	          //if a booking was booked by the current account, change the button to "BOOKED" and disable it
	          $('.panel-property').eq(i).find('button').text('BOOKED').attr('disabled', true).addClass('btn-success');
	        
	        }else if(bookings[i] !== '0x0000000000000000000000000000000000000000'){
	          //if a booking is found from another booker, disable its booking buttona and change text to "UNAVAILABLE"
	          $('.panel-property').eq(i).find('button').text('UNAVAILABLE').attr('disabled', true);
	        }
	      }
	
	    }).catch(function(err){
	      console.log(err.message);
	    });
	  },

###8. Implement Money Spending

Now, we have a working interface that interacts with the blockchain. Now we must add functionality to transfer the booking rate from the booker's account. To do this, we will add some code to our smart contract and to app.js.

First, modify the book() function in the Booking.sol smart contract. In the header, add the keyword "payable" - this makes our function able to handle value, and it will expect value to be passed in. Then, in the function itself, add the following code before the return:

	receiveValue.transfer(msg.value);

Your book() function should now look like this:

	//book a property by adding the address of the booker to the bookings array
	  function book(uint propertyId) payable public returns(uint){
	    require(propertyId >= 0 && propertyId <= 7);
	    booker = msg.sender;
	    bookings[propertyId] = booker;
	
	    //pay contract from buyer's account
	    receiveValue.transfer(msg.value);
	    return propertyId;
	  }
  
Notice that we are transferring the value to receiveValue, which is an address we declared in our variables. Here we have set this to '0x0' - change the address to whichever address you want to receive the funds. This should not be the same address we pass in (which we will implement next in app.js).

In app.js, we will now make a change to the handleBook function. Near the beginning of the function, add the following line to get the booking rate from the button data:

	var _rate = parseFloat($(event.target).data('value'));
	
Then, in the call to the book() function, add the value, converted to wei:

	return bookingInstance.book(propertyId, {from: App.account, value: web3.toWei(_rate, "ether"), gas: 500000});

Your handleBook function should now look like this:

	handleBook: function(event) {
	    event.preventDefault();
	
	    var propertyId = parseInt($(event.target).data('id'));
	    var bookingInstance;
	    //pull rate out of button value
	    var _rate = parseFloat($(event.target).data('value'));
	    var contractAddress = App.contracts.Booking.address; //GET CONTRACT ADDRESS
	
	    web3.eth.getAccounts(function(error, accounts){
	      if(error){
	        console.log(error);
	      }
	      App.contracts.Booking.deployed().then(function(instance){
	        bookingInstance = instance;
	        //Execute book() - note, since it is a transaction we must send the from address and the value
	        return bookingInstance.book(propertyId, {from: App.account, value: web3.toWei(_rate, "ether"), gas: 500000});
	      }).then(function(result){
	        return App.markBooked();
	      }).catch(function(err){
	        console.log(err.message);
	      });
	    });
	  }

Now, we are ready to redeploy! Because we made changes to our smart contract, we need to re-run the truffle migration. Execute the following commands in terminal:

	truffle migrate --compile-all --reset --network development
	
	npm run dev 

And now, you have a dapp!