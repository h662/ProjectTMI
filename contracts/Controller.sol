// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Tree.sol";
import "./Berry.sol";

contract Controller is Ownable {
    Berry berryContract;

    constructor() {}

    function setBerryContract(address _berryContract) public onlyOwner {
        berryContract = Berry(_berryContract);
    }

    function bear() public {
        berryContract.mintBerry(msg.sender, 100);
    }
} 