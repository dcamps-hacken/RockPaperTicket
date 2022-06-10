interface EventLog {
    function _logEvent(
        uint256 _eventId,
        address _eventGameAddress,
        address _eventOwner,
        string memory _eventName,
        uint256 _numberOfTickets,
        uint256 _ticketPrice
    ) external;

    function _updateName(uint256 _eventId, string memory _newName) external;

    function _updateTickets(uint256 _eventId, uint256 _newTickets) external;

    function _updatePrice(uint256 _eventId, uint256 _newPrice) external;

    function getEventName(uint256 _eventId)
        external
        view
        returns (string memory);

    function getNumberOfTickets(uint256 _eventId)
        external
        view
        returns (uint256);

    function _addRegisteredEvent(address _userAddress, uint256 _eventId)
        external;

    function _addCreatedEvent(address _userAddress, uint256 _eventId) external;

    function _gameStart(uint256 _eventId) external;

    function _closeEvent(uint256 _eventId) external;

    function _addWinner(uint256 _eventId, address _winner) external;

    function _isWinner(uint256 _eventId, address _userAddress)
        external
        view
        returns (bool);
}

interface VRF {
    function requestRandomWords() external;

    function _getRandomNumber(uint256 _playId) external view returns (uint256);

    function _haveNumbers() external view returns (bool);
}
