// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Berry.sol";
import "./Ground.sol";

contract Tree is ERC721Enumerable, Ownable {
    struct TreeData {
        uint level;
        uint[] berryId;
        uint[] berryAmount;
        uint[] requireBerryId;
        uint[] requireBerryAmount;
        bool isMaxLevel;
        uint nextTreeId;
    }
    
    mapping(uint => uint) trees;
    mapping(uint => TreeData) public treeData;
    mapping(uint => uint) bearTime; 
    mapping(uint => string) metadataUri;
    mapping(uint => bool) public isPlanted;

    address berryAddress;
    Berry berryContract;
    address groundAddress;
    Ground groundContract;

    uint treeDataId;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    modifier treeOwner(uint _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "Not tree owner.");
        _;
    }

    modifier isTransferable(uint _tokenId) {
        require(!isPlanted[_tokenId], "Already planted");
        _;
    }

    function mintTree(uint _treeDataId) public onlyOwner {
        require(treeData[_treeDataId].berryAmount[0] > 0, "Not exist tree.");
        require(treeData[_treeDataId].level == 1, "Not level 1.");

        uint tokenId = totalSupply() + 1;

        trees[tokenId] = _treeDataId;

        _mint(msg.sender, tokenId);
    }

    function setTreeData(
        uint _level,
        uint[] memory _berryId, 
        uint[] memory _berryAmount, 
        uint[] memory _requireBerryId, 
        uint[] memory _requireBerryAmount,
        bool _isMaxLevel,
        uint _nextTreeId,
        string memory _metadataUri
        ) public onlyOwner {
            require(_berryId.length == _berryAmount.length, "Not equal _berryId & _berryAmount length.");
            require(_requireBerryId.length == _requireBerryAmount.length, "Not equal _requireBerryId & _requireBerryAmount length.");

            treeDataId++;

            treeData[treeDataId] = TreeData(
                _level, 
                _berryId, 
                _berryAmount, 
                _requireBerryId, 
                _requireBerryAmount, 
                _isMaxLevel,
                _nextTreeId
            );
            
            metadataUri[treeDataId] = _metadataUri;
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        uint _treeDataId = trees[_tokenId];

        return metadataUri[_treeDataId];
    }

    function getBerryAmount(uint _tokenId) public view returns(uint[] memory, uint[] memory) {
        uint _treeDataId = trees[_tokenId];

        uint[] memory _berryId = treeData[_treeDataId].berryId;
        uint[] memory _berryAmount = treeData[_treeDataId].berryAmount;

        return (_berryId, _berryAmount);
    }

    function setBearTime(uint _tokenId, uint _bearTime) public {
        require(berryAddress == msg.sender, "U R not Berry.");

        bearTime[_tokenId] = _bearTime;
    }

    function getBearTime(uint _tokenId) public view returns(uint) {
        return bearTime[_tokenId];
    }

    function setBerryContract(address _berryAddress) public onlyOwner {
        berryAddress = _berryAddress;
        berryContract = Berry(_berryAddress);
    }
    function setGroundContract(address _groundAddress) public onlyOwner {
        groundAddress = _groundAddress;
        groundContract = Ground(_groundAddress);
    }


    function levelUp(uint _tokenId) public treeOwner(_tokenId) {
        uint _treeDataId = trees[_tokenId];

        require(!treeData[_treeDataId].isMaxLevel, "Max level.");
        require(berryCheck(_treeDataId), "Not enough berry.");

        berryContract.burnBerry(msg.sender, treeData[_treeDataId].requireBerryId, treeData[_treeDataId].requireBerryAmount);
        trees[_tokenId] = treeData[_treeDataId].nextTreeId;
    }

    function berryCheck(uint _treeDataId) public view returns(bool) {
        bool result = true;

        for(uint i = 0; i < treeData[_treeDataId].requireBerryId.length; i++) {
            if(treeData[_treeDataId].requireBerryAmount[i] > berryContract.balanceOf(msg.sender, treeData[_treeDataId].requireBerryId[i])) {
                result = false;
            }
        }

        return result;
    }

    function plantTree(address _groundOwner, uint _tokenId) public {
        require(msg.sender == groundAddress, "Caller is not ground contract.");
        require(!isPlanted[_tokenId], "Already planted.");
        require(ownerOf(_tokenId) == _groundOwner, "U R not tree owner.");

        isPlanted[_tokenId] = true;
    }

    function popTree(address _groundOwner, uint _tokenId) public {
        require(msg.sender == groundAddress, "Caller is not ground contract");
        require(isPlanted[_tokenId], "Not planted.");
        require(ownerOf(_tokenId) == _groundOwner, "U R not tree owner.");

        isPlanted[_tokenId] = false;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override isTransferable(tokenId) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override isTransferable(tokenId) {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override isTransferable(tokenId) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }
}