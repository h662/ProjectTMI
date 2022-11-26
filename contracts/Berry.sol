// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import './Tree.sol';

contract Berry is ERC20, Ownable {
    address treeAddress;
    Tree treeContract;

    constructor() ERC20("TMI Berry", "TB") {}

    function bearBerry(uint _treeId) public {
        require(treeContract.ownerOf(_treeId) == msg.sender, "Caller is not tree owner.");
        require(treeContract.getBearTime(_treeId) < block.timestamp, "Not yet.");

        _mint(msg.sender, treeContract.getBerryAmount(_treeId) * 10**18);
        treeContract.setBearTime(_treeId, block.timestamp + 60);
    }

    function setTreeContract(address _treeAddress) public onlyOwner {
        treeAddress = _treeAddress;
        treeContract = Tree(_treeAddress);
    }

    function burnBerry(address _treeOwner, uint _amount) public {
        require(treeAddress == msg.sender, "U R not tree.");

        _burn(_treeOwner, _amount);
    }
}