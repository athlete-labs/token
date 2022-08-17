// contracts/AthleteToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract AthleteToken is ERC1155{

    uint public initialSupply = 100000000e8;
    uint256 public constant ATH = 0;
    mapping(address => Operator) public operators;

    struct Operator {
        uint8 level;
        bool active;
    }

    constructor() ERC1155("ipfs://f0{id}") {
        _mint(msg.sender, ATH, initialSupply, "");
    }

    function mint(uint256 id) public {
        require(operators[msg.sender].active == true);
        _mint(msg.sender, id, 1000000e8, "");
    }

    function registerOperator(address _user) public {
        require(operators[msg.sender].level > 9);
        operators[_user] = Operator(1, true);
    }

    function changeOperatorLevel(address _user, uint8 _newLevel) public {
        require(operators[msg.sender].level > 9);
        operators[_user].level = _newLevel;
    }
}
