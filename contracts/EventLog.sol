pragma solidity 0.8.4;

//This contract is a log of the created events

//Error codes
error EventLog__NotCalledFromEventGame();
error EventLog__GameNotRegistering();
error EventLog__GameNotStarted();

/** @title
 *  @author David Camps Novi
 *  @dev This contract saves all events and their details and allows to query data
 */
// solc --userdoc --devdoc EventLog.sol
contract EventLog {
    // all events ever created are stored in these structures
    uint256 private s_numberOfEvents;
    uint256[] s_eventIds;
    mapping(uint256 => Event) s_events; // s_eventId => Event

    // every user events are stored as userAddress => Event
    mapping(address => uint256[]) s_registeredEvents;
    mapping(address => uint256[]) s_createdEvents;

    // the winners of each event are stored as s_eventId => userAddress => true
    mapping(uint256 => mapping(address => bool)) s_winners;

    enum GameStatus {
        Registering,
        Started,
        Ended
    }

    struct Event {
        address eventGameAddress;
        address eventOwner;
        string eventName;
        uint256 numberOfTickets;
        uint256 ticketPrice;
        uint256 totalUsers;
        GameStatus status;
    }

    //modifier callFromEvent() {
    //    if (msg.sender != s_events[_eventId].eventGameAddress)
    //        revert EventLog__NotCalledFromEventGame();
    //    _;
    //}

    constructor() {
        s_numberOfEvents = 0;
    }

    event GameStarted(
        address indexed gameAddress,
        address indexed owner,
        uint256 timeStarted
    );

    event GameEnded(
        address indexed gameAddress,
        address indexed owner,
        uint256 timeStarted
    );

    //
    // LOG NEW EVENTS
    //

    function _logEvent(
        uint256 _eventId,
        address _eventGameAddress,
        address _eventOwner,
        string memory _eventName,
        uint256 _numberOfTickets,
        uint256 _ticketPrice
    ) external {
        s_events[_eventId] = Event(
            _eventGameAddress,
            _eventOwner,
            _eventName,
            _numberOfTickets,
            _ticketPrice,
            0,
            GameStatus.Registering
        );
        s_numberOfEvents += 1;
        s_eventIds.push(_eventId);
    }

    //
    // UPDATE EVENTS
    //

    function _updateName(uint256 _eventId, string memory _newName)
        external
    //callFromEvent
    {
        if (msg.sender != s_events[_eventId].eventGameAddress)
            revert EventLog__NotCalledFromEventGame();
        s_events[_eventId].eventName = _newName;
    }

    function _updateTickets(uint256 _eventId, uint256 _newTickets) external {
        if (msg.sender != s_events[_eventId].eventGameAddress)
            revert EventLog__NotCalledFromEventGame();
        s_events[_eventId].numberOfTickets = _newTickets;
    }

    function _updatePrice(uint256 _eventId, uint256 _newPrice) external {
        if (msg.sender != s_events[_eventId].eventGameAddress)
            revert EventLog__NotCalledFromEventGame();
        s_events[_eventId].ticketPrice = _newPrice;
    }

    // LOG OTHER EVENTS
    function _addRegisteredEvent(address _userAddress, uint256 _eventId)
        external
    {
        if (msg.sender != s_events[_eventId].eventGameAddress)
            revert EventLog__NotCalledFromEventGame();
        s_registeredEvents[_userAddress].push(_eventId);
        s_events[_eventId].totalUsers += 1;
    }

    function _addCreatedEvent(address _userAddress, uint256 _eventId) external {
        //require(msg.sender == s_events[_eventId].eventGameAddress);
        s_createdEvents[_userAddress].push(_eventId);
    }

    //
    // CHANGE GAME STATUS
    //

    function _gameStart(uint256 _eventId) external {
        if (msg.sender != s_events[_eventId].eventGameAddress)
            revert EventLog__NotCalledFromEventGame();
        if (s_events[_eventId].status != GameStatus.Registering)
            revert EventLog__GameNotRegistering();
        //require(s_events[_eventId].status == GameStatus.Registering);
        s_events[_eventId].status = GameStatus.Started;
        Event memory _event = s_events[_eventId];
        emit GameStarted(
            _event.eventGameAddress,
            _event.eventOwner,
            block.timestamp
        );
    }

    function _gameEnd(uint256 _eventId) external {
        if (msg.sender != s_events[_eventId].eventGameAddress)
            revert EventLog__NotCalledFromEventGame();
        if (s_events[_eventId].status != GameStatus.Started)
            revert EventLog__GameNotStarted();
        //require(s_events[_eventId].status == GameStatus.Started);
        s_events[_eventId].status = GameStatus.Ended;
        Event memory _event = s_events[_eventId];
        emit GameEnded(
            _event.eventGameAddress,
            _event.eventOwner,
            block.timestamp
        );
    }

    //
    // CHANGE GAME STATUS
    //

    function _addWinner(uint256 _eventId, address _winner) external {
        if (msg.sender != s_events[_eventId].eventGameAddress)
            revert EventLog__NotCalledFromEventGame();
        s_winners[_eventId][_winner] = true;
    }

    //
    // GETTER FUNCTIONS
    //

    function getNumberOfEvents() public view returns (uint256) {
        return s_numberOfEvents;
    }

    function getEvent(uint256 _eventId) public view returns (Event memory) {
        Event memory newEvent = s_events[_eventId];
        return newEvent;
    }

    function getEventAddress(uint256 _eventId) public view returns (address) {
        return s_events[_eventId].eventGameAddress;
    }

    function getEventOwner(uint256 _eventId) public view returns (address) {
        return s_events[_eventId].eventOwner;
    }

    function getTicketPrice(uint256 _eventId) public view returns (uint256) {
        return s_events[_eventId].ticketPrice;
    }

    function getTotalUsers(uint256 _eventId) public view returns (uint256) {
        return s_events[_eventId].totalUsers;
    }

    //function getGameStatus(uint256 _eventId) public view returns (uint8) {
    //    return s_events[_eventId].status;
    //}

    function getEventName(uint256 _eventId)
        external
        view
        returns (string memory)
    {
        return s_events[_eventId].eventName;
    }

    function getNumberOfTickets(uint256 _eventId)
        external
        view
        returns (uint256)
    {
        uint256 numberOfTickets = s_events[_eventId].numberOfTickets;
        return numberOfTickets;
    }

    function getOpenEvents() public view returns (Event[] memory) {
        uint256 availableLength = 0;
        for (uint256 i = 1; i <= s_numberOfEvents; i++) {
            if (s_events[i].status == GameStatus.Registering) {
                availableLength += 1;
            }
        }

        Event[] memory openEvents = new Event[](availableLength);
        uint256 currentIndex = 0;
        for (uint256 i = 1; i <= s_numberOfEvents; i++) {
            if (s_events[i].status == GameStatus.Registering) {
                openEvents[currentIndex] = s_events[i];
                currentIndex += 1;
            }
        }
        return openEvents;
    }

    function getRegisteredEvents(address _userAddress)
        public
        view
        returns (Event[] memory)
    {
        uint256[] memory registeredEvents = s_registeredEvents[_userAddress];
        uint256 availableLength = registeredEvents.length;
        Event[] memory registeredEventsStruct = new Event[](availableLength);
        for (uint256 i = 0; i < availableLength; i++) {
            uint256 eventId = registeredEvents[i];
            Event memory newEvent = s_events[eventId];
            registeredEventsStruct[i] = newEvent;
        }
        return registeredEventsStruct;
    }

    function getCreatedEvents(address _userAddress)
        public
        view
        returns (Event[] memory)
    {
        uint256[] memory createdEvents = s_createdEvents[_userAddress];
        uint256 availableLength = createdEvents.length;
        Event[] memory createdEventsStruct = new Event[](availableLength);
        for (uint256 i = 0; i < availableLength; i++) {
            uint256 eventId = createdEvents[i];
            Event memory newEvent = s_events[eventId];
            createdEventsStruct[i] = newEvent;
        }
        return createdEventsStruct;
    }

    function _isWinner(uint256 _eventId, address _userAddress)
        external
        view
        returns (bool)
    {
        return s_winners[_eventId][_userAddress];
    }
}
