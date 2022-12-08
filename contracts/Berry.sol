// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Tree.sol";

contract Berry is ERC1155, Ownable {
    string public name;
    string public symbol;
    mapping(uint => string) metadataUri;
    address treeAddress;
    Tree treeContract;

    constructor(string memory _name, string memory _symbol) ERC1155("") {
        name = _name;
        symbol = _symbol;
    }

    function bearBerry(uint _treeId) public {
        require(treeContract.ownerOf(_treeId) == msg.sender, "Caller is not tree owner.");
        require(treeContract.getBearTime(_treeId) < block.timestamp, "Not yet.");

        (uint[] memory _berryId, uint[] memory _berryAmount) = treeContract.getBerryAmount(_treeId);

        for(uint i = 0; i < _berryId.length; i++) {
            _mint(msg.sender, _berryId[i], _berryAmount[i], "");
        }

        // 하루로 변경
        treeContract.setBearTime(_treeId, 60);
    }

    function setUri(uint _tokenId, string memory _metadataUri) public onlyOwner {
        metadataUri[_tokenId] = _metadataUri;
    }

    function uri(uint _tokenId) public override view returns(string memory) {
        return metadataUri[_tokenId];
    }

    function setTreeContract(address _treeAddress) public onlyOwner {
        treeAddress = _treeAddress;
        treeContract = Tree(_treeAddress);
    }

    function burnBerry(address _treeOwner, uint[] memory _berryId, uint[] memory _berryAmount) public {
        require(treeAddress == msg.sender, "U R NOT BERRY");

        for(uint i = 0; i < _berryId.length; i++) {
            _burn(_treeOwner, _berryId[i], _berryAmount[i]);
        }
    }
}