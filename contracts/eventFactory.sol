pragma solidity 0.8.4;

// This contract
// 1) is a factory of eventGame contracts
// 2) records every event created

import "./eventGame.sol";

/** @title A contract for crowd funding
 *  @author David Camps Novi
 *  @dev This is a Factory contract to deploy eventGame contracts and log all its info
 */
contract EventFactory {
    address private immutable i_logAddress;
    address private immutable i_vrfAddress;
    uint256 private s_nextId;

    constructor(address _logAddress, address _vrfAddress) {
        i_logAddress = _logAddress;
        i_vrfAddress = _vrfAddress;
        s_nextId = 1;
    }

    /**
     *  @dev This function creates gameEvent contracts and logs all its info into eventLog
     *  @param _eventName is the name chosen by the owner of the event
     *  @param _numberOfTickets is the number of tickets available for the event
     *  @param _ticketPrice is the price at which the tickets will be sold
     *  @return It returns the address of the created gameEvent
     */
    function createEventGame(
        string memory _eventName,
        uint256 _numberOfTickets,
        uint256 _ticketPrice
    ) external returns (address) {
        EventLog log = EventLog(i_logAddress);
        EventGame game = new EventGame(
            i_logAddress,
            i_vrfAddress,
            msg.sender,
            s_nextId
        );
        log._logEvent(
            s_nextId,
            address(game),
            msg.sender,
            _eventName,
            _numberOfTickets,
            _ticketPrice
        );
        log._addCreatedEvent(msg.sender, s_nextId);
        s_nextId += 1;
        return address(game);
    }

    function getVrfAddress() external view returns (address) {
        return (i_vrfAddress);
    }

    function getLogAddress() external view returns (address) {
        return (i_logAddress);
    }

    function getNextId() external view returns (uint256) {
        return (s_nextId);
    }
}
