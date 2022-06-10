pragma solidity 0.8.4;

import "contracts/ILogVRF.sol";

contract EventGame {
    // constant variables since the creation of the event
    address immutable s_logAddress;
    address immutable s_vrfAddress;
    address immutable s_owner;
    uint256 public immutable s_eventId;

    enum GameStatus {
        Registering,
        Started,
        Ended
    }

    GameStatus public status;

    // constructor that defines all variables described above
    constructor(
        address _logAddress,
        address _vrfAddress,
        address _owner,
        uint256 _eventId
    ) {
        // definition of constant variables
        s_logAddress = _logAddress;
        s_vrfAddress = _vrfAddress;
        s_owner = _owner;
        s_eventId = _eventId;
    }

    modifier isRegistering() {
        require(status == GameStatus.Registering);
        _;
    }

    modifier isStarted() {
        require(status == GameStatus.Started);
        _;
    }

    modifier isEnded() {
        require(status == GameStatus.Ended);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    // registration and user-related variables
    address[] public s_registeredAddresses;
    mapping(address => bool) public s_isRegistered;
    mapping(address => UserScore) public scoreboard;
    mapping(uint256 => address[]) s_groups;
    struct UserScore {
        uint256 points;
        uint256 numberOfPlays;
        uint256 timeElapsed;
    }

    // game-related variables
    uint256 timeLimit; // time at which users can't make more plays
    enum PossiblePlays {
        Rock,
        Paper,
        Scissors
    }

    // emission of events for each play result
    event result(
        address indexed gameAddress,
        address indexed player,
        string result,
        uint256 points
    );

    //
    // UPDATE EVENTS
    //

    function getEventId() external view returns (uint256) {
        return s_eventId;
    }

    function updateName(string memory _newName) public onlyOwner isRegistering {
        EventLog log = EventLog(s_logAddress);
        log._updateName(s_eventId, _newName);
    }

    function updateTickets(uint256 _newTickets) public onlyOwner isRegistering {
        EventLog log = EventLog(s_logAddress);
        log._updateTickets(s_eventId, _newTickets);
    }

    function updatePrice(uint256 _newPrice) public onlyOwner isRegistering {
        EventLog log = EventLog(s_logAddress);
        log._updatePrice(s_eventId, _newPrice);
    }

    //
    // REGISTRATION
    //

    // Registration of buyers => checks multi-registration
    function register() public isRegistering {
        require(
            s_isRegistered[msg.sender] == false,
            "You have already registered!"
        ); // ensure the person have not registered
        UserScore memory initialUserScore = UserScore(0, 0, block.timestamp);
        scoreboard[msg.sender] = initialUserScore;
        s_registeredAddresses.push(msg.sender);
        s_isRegistered[msg.sender] = true;
        EventLog log = EventLog(s_logAddress);
        log._addRegisteredEvent(msg.sender, s_eventId);
    }

    //
    // START GAME ---> manually activated by organizer
    //

    // Random numbers generation is called in this function (VRF node calls)
    function startGame() public isRegistering {
        status = GameStatus.Started;
        //VRF vrf = VRF(s_vrfAddress);
        //vrf.requestRandomWords();
        EventLog log = EventLog(s_logAddress);
        uint256 numberOfTickets = log.getNumberOfTickets(s_eventId);
        uint256 numberOfPlayers = s_registeredAddresses.length;
        if (numberOfTickets >= numberOfPlayers) {
            for (uint256 i = 0; i < numberOfPlayers; i++) {
                log._addWinner(s_eventId, s_registeredAddresses[i]);
            }
        }
        log._gameStart(s_eventId);
        timeLimit = block.timestamp + 1000000000000000;
        //_createGroups();
    }

    // Groups are created when the game is started
    function _createGroups() private {
        EventLog log = EventLog(s_logAddress);
        uint256 numberOfTickets = log.getNumberOfTickets(s_eventId);
        uint256 numberOfPlayers = s_registeredAddresses.length;
        uint256 lastGroupPlayers = numberOfPlayers % numberOfTickets;
        uint256 groupLen = (numberOfPlayers - lastGroupPlayers) /
            numberOfTickets;
        _createLastGroup(numberOfTickets, numberOfPlayers, groupLen);
        _createSubGroups(numberOfTickets, groupLen);
    }

    function _createLastGroup(
        uint256 _numberOfTickets,
        uint256 _numberOfPlayers,
        uint256 _groupLen
    ) private {
        address[] memory lastGroup;
        uint256 startIndex = (_numberOfTickets - 1) * _groupLen;
        uint256 j = 0;
        for (uint256 i = startIndex; i < _numberOfPlayers; i++) {
            lastGroup[j] = s_registeredAddresses[i];
            j += 1;
        }
        s_groups[_numberOfTickets - 1] = lastGroup;
    }

    function _createSubGroups(uint256 _numberOfTickets, uint256 _groupLen)
        private
    {
        uint256 groupId;
        for (groupId = 0; groupId < _numberOfTickets - 1; groupId++) {
            address[] memory subGroup;
            uint256 shift = groupId * _groupLen;
            for (uint256 i = 0; i < _groupLen; i++) {
                subGroup[i] = s_registeredAddresses[i + shift];
            }
            s_groups[groupId] = subGroup;
        }
    }

    //
    // GAME MECHANICS --> some time has to pass so that random numbers are generated!
    //

    function userPlay(uint256 _play) public {
        //isStarted {
        //VRF vrf = VRF(s_vrfAddress);
        //require(
        //    vrf._haveNumbers(),
        //    "Calculating algorithmic play, please wait..."
        //);
        uint256 playId = scoreboard[msg.sender].numberOfPlays;
        require(s_isRegistered[msg.sender] == true, "You are not registered!");
        require(playId <= 5, "You have already made all your plays!");
        //require(block.timestamp < timeLimit, "The game is alredy finished");
        PossiblePlays algoPlay = _getAlgoPlay(playId);
        if (PossiblePlays(_play) == algoPlay) {
            emit result(address(this), msg.sender, "draw", 1);
            scoreboard[msg.sender].points += 1;
        } else if (
            PossiblePlays(_play) == PossiblePlays(0) &&
            algoPlay == PossiblePlays(1)
        ) {
            emit result(address(this), msg.sender, "loss", 0);
        } else if (
            PossiblePlays(_play) == PossiblePlays(0) &&
            algoPlay == PossiblePlays(2)
        ) {
            emit result(address(this), msg.sender, "win", 3);
            scoreboard[msg.sender].points += 3;
        } else if (
            PossiblePlays(_play) == PossiblePlays(1) &&
            algoPlay == PossiblePlays(0)
        ) {
            emit result(address(this), msg.sender, "win", 3);
            scoreboard[msg.sender].points += 3;
        } else if (
            PossiblePlays(_play) == PossiblePlays(1) &&
            algoPlay == PossiblePlays(2)
        ) {
            emit result(address(this), msg.sender, "loss", 0);
        } else if (
            PossiblePlays(_play) == PossiblePlays(2) &&
            algoPlay == PossiblePlays(0)
        ) {
            emit result(address(this), msg.sender, "loss", 0);
        } else {
            emit result(address(this), msg.sender, "win", 3);
            scoreboard[msg.sender].points += 3;
        }
        scoreboard[msg.sender].numberOfPlays += 1;
        scoreboard[msg.sender].timeElapsed += block.timestamp;
    }

    function _getAlgoPlay(
        uint256 _playId //must be changed back to private
    ) public view returns (PossiblePlays) {
        //VRF vrf = VRF(s_vrfAddress);
        //uint256 randomNum = vrf._getRandomNumber(_playId);
        //PossiblePlays algoPlay = PossiblePlays(randomNum);

        PossiblePlays algoPlay = PossiblePlays(1);
        return algoPlay;
    }

    //
    // FINISH THE GAME & SET THE WINNERS
    //

    function endGame() public isStarted {
        status = GameStatus.Ended;
        _setWinners(); // this function is incomplete
    }

    function _setWinners() private {
        EventLog log = EventLog(s_logAddress);
        uint256 numberOfTickets = log.getNumberOfTickets(s_eventId);
        for (uint256 groupId = 0; groupId < numberOfTickets; groupId++) {
            address winner = _calculateWinner(groupId);
            log._addWinner(s_eventId, winner);
        }
    }

    // calculate the winner of a given group
    function _calculateWinner(uint256 _groupId) private view returns (address) {
        address[] memory group = s_groups[_groupId]; // array with all the addresses of the group
        uint256 groupLen = group.length;
        uint256[] memory points = _returnGroupPoints(group, groupLen);
        uint256 maxNum = _returnMaxNum(points);
        address winner = _returnGroupWinner(group, maxNum, groupLen);
        return winner;
    }

    // Return the points in a group
    function _returnGroupPoints(address[] memory _group, uint256 _groupLen)
        private
        view
        returns (uint256[] memory)
    {
        uint256[] memory points; // array with all the points of the group
        for (uint256 i = 0; i < _groupLen; i++) {
            points[i] = scoreboard[_group[i]].points;
        }
        return points;
    }

    // Return the maximum points in a group
    function _returnMaxNum(uint256[] memory _points)
        private
        pure
        returns (uint256)
    {
        uint256 maxNum = 0;
        for (uint256 i = 0; i < _points.length; i++) {
            if (_points[i] > maxNum) {
                maxNum = _points[i];
            }
        }
        return maxNum;
    }

    // Return the winner for a given group --> CHECK THIS FUNCTION
    function _returnGroupWinner(
        address[] memory _group,
        uint256 _maxNum,
        uint256 _groupLen
    ) private view returns (address) {
        address[] memory winners; // defined as array to cover case of several users having same points
        address winner;
        uint j = 0;
        for (uint256 i = 0; i < _groupLen; i++) {
            address user = _group[i];
            if (scoreboard[user].points == _maxNum) {
                winners[j] = user;
                j += 1;
            }
        }
        if (winners.length == 1) {
            winner = winners[0];
        } else {
            winner = _compareTimes(winners);
        }
        return winner;
    }

    // returns the fastest player in a winners[] array
    function _compareTimes(address[] memory _winners)
        private
        view
        returns (address)
    {
        uint256 bestTime = block.timestamp;
        address winner;
        for (uint256 i = 0; i < _winners.length; i++) {
            address user = _winners[i];
            uint256 userTime = scoreboard[user].timeElapsed;
            if (userTime < bestTime) {
                bestTime = userTime;
                winner = user;
            }
        }
        return winner;
    }

    //
    // QUERY WINNERS AND SCOREBOARD
    //

    function getScoreboard() public view returns (UserScore memory) {
        return scoreboard[msg.sender];
    }

    function isWinner(address _userAddress) external view returns (bool) {
        EventLog log = EventLog(s_logAddress);
        return log._isWinner(s_eventId, _userAddress);
    }
}
