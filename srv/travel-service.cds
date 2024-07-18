using { sap.fe.cap.travel as my } from '../db/schema';

service TravelService @(path:'/processor') {

  @(restrict: [
    { grant: 'READ', to: 'authenticated-user'},
    { grant: ['rejectTravel','acceptTravel','deductDiscount'], to: 'reviewer'},
    { grant: ['*'], to: 'processor'},
    { grant: ['*'], to: 'admin'}
  ])
  entity Travel as projection on my.Travel actions {
    action createTravelByTemplate() returns Travel;
    action rejectTravel();
    action acceptTravel();
    action deductDiscount(@(UI.ParameterDefaultValue : 5)percent: Percentage not null @mandatory ) returns Travel;
  };

  // Passenger: Add joined property 'FullName' and association 'to_Booking'
  entity Passenger as projection on my.Passenger {
    *,
    FirstName || ' ' || LastName as FullName: String @title : '{i18n>fullName}',
    to_Booking: Association to many my.Booking on to_Booking.to_Customer = $self
  }

  entity SupplementScope as projection on my.SupplementScope;
  // Ensure all masterdata entities are available to clients
  annotate my.MasterData with @cds.autoexpose @readonly;

  // Function import used in Controller Extension 'PassengerOPExtend.js' to calculate booking data
  function getBookingDataOfPassenger(CustomerID: String) returns my.BookingData;
}

type Percentage : Integer @assert.range: [1,100];
