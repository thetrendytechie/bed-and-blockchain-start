pragma solidity ^0.4.19;
//these are part of the truffle system
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
//import Booking contract
import "../contracts/Booking.sol";

contract TestBooking{
  Booking booking = Booking(DeployedAddresses.Booking());

  //test the book() function
  function testUserCanBookProperty() public {
    uint returnedId = booking.book(3);
    uint expected = 3;

    Assert.equal(returnedId, expected, "Property ID 3 should be returned after booking.");
  }
  //test that once a property is booked, its booker can be retrieved
  function testGetBookerAddressByPropertyId() public {
      //expected booker is this contract
      address expected = this;
      address booker = booking.bookings(3);
      //3 because this is the one we tested in the first test
      //we can do this because public variables have automatic getters

      Assert.equal(booker, expected, "Booker of property 3 should be recorded.");

  }

  //test that we can get all bookings
  function testGetBooker() public {
    //expected booker is this contract
    address expected = this;

    //store bookings in memory rather than the contract's storage
    address[8] memory bookings = booking.getBookings();

    Assert.equal(bookings[3], expected, "Booker of property 3 should be recorded.");
  }
}
