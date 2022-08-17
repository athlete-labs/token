// contracts/AthleteToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract AthleteToken is ERC1155 {

    uint256 public initialSupply = 100000000e8;
    uint256 public constant ATH = 0;
    uint256 public tokenTotalStake;
    uint256 public difficultyPerBlock;
    address public communityPool = msg.sender;
    uint256 public fee;

    Sport[] public sports;

    mapping(address => Operator) public operators;
    mapping(address => Athlete) public athletes;
    mapping(address => Sponsor) public sponsors;
    mapping(address => mapping(uint => Stake)) public stakeSubscriptions;
    
    struct Operator {
        uint8 level;
        bool active;
    }

    struct Sport {
        uint8 id;
        string name;
    }

    struct Athlete {
        uint8 sport;
        string name;
        string url;
        bool active;
    }

    struct Sponsor {
        string name;
        string url;
        bool active;
    }

    struct Stake {
        uint amount;
        uint blockId;
    }

    constructor() ERC1155("ipfs://f0{id}") {
        _mint(msg.sender, ATH, initialSupply, "");
        sports.push(Sport(1, "soccer"));
        sports.push(Sport(2, "tenis"));
        sports.push(Sport(3, "basketball"));
        fee = 500000;
    }

    function payFee() public {
        _burn(msg.sender, 0, fee);
        _mint(communityPool, 0, fee, "");
    }

    function mintAthleteToken(uint256 id) public {
        require(operators[msg.sender].active == true);
        _mint(msg.sender, id, 1000000e8, "");
    }

    function mintAthleteNFT(uint256 id) public {
        require(operators[msg.sender].active == true);
        _mint(msg.sender, id, 1, "");
    }

    function registerOperator(address _user) public {
        require(operators[msg.sender].level > 9);
        operators[_user] = Operator(1, true);
    }

    function changeOperatorLevel(address _user, uint8 _newLevel) public {
        require(operators[msg.sender].level > 9);
        operators[_user].level = _newLevel;
    }

    function registerAthlete(address _user, uint8 _idSport, string memory _name, string memory _url) public {
        require(!athletes[_user].active);
        athletes[_user] = Athlete(_idSport, _name, _url, true);
        payFee();
    }

    function registerSponsor(address _user, string memory _name, string memory _url) public {
        require(!sponsors[_user].active);
        sponsors[_user] = Sponsor(_name, _url, true);
        payFee();
    }

    function createSport(string memory _sportName) public {
        require(operators[msg.sender].level > 9);
        sports.push(Sport(3, _sportName));
    }

    function subscribeStake(uint256 _amount) public {
        require(balanceOf(msg.sender, 0) >= _amount);
        require(_amount > (100e8));
        require(stakeSubscriptions[msg.sender][block.number].amount == 0);
        _burn(msg.sender, 0, _amount);
        tokenTotalStake += _amount;
        stakeSubscriptions[msg.sender][block.number] = Stake(_amount, block.number);
        difficultyPerBlock = (initialSupply + (tokenTotalStake * 10)) / 100;
    }

    function unsubscribeStake(uint256 _blockNumber) public {
        uint amountStake = stakeSubscriptions[msg.sender][_blockNumber].amount;
        uint timeBlocks = (block.number - _blockNumber) * initialSupply;
        require(amountStake > 0);
        require(block.number > _blockNumber);
        tokenTotalStake -= amountStake;
        uint rewards = amountStake / (difficultyPerBlock / timeBlocks);
        _mint(msg.sender, 0, amountStake + rewards, "");
        stakeSubscriptions[msg.sender][_blockNumber].amount = 0;
        payFee();
    }

}
