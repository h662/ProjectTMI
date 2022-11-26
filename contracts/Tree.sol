// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import './Berry.sol';

contract Tree is ERC721Enumerable, Ownable {
    struct TreeData {
        uint level;
        string color;
        string shape;
        uint berryAmount;
        uint exp;
        bool isMaxLevel;
    }
    
    mapping(uint => uint) trees;
    mapping(uint => TreeData) treeData;
    // 변수명
    mapping(uint => uint) bearTime; 

    string metadataURI;

    address berryAddress;
    Berry berryContract;

    uint public treeDataId;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    modifier treeOwner(uint _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "Not tree owner.");
        _;
    }

    function mintTree(uint _treeDataId) public onlyOwner {
        require(treeData[_treeDataId].berryAmount > 0, "Not exist tree.");
        require(treeData[_treeDataId].level == 1, "Not level 1.");

        uint tokenId = totalSupply() + 1;

        trees[tokenId] = _treeDataId;

        _mint(msg.sender, tokenId);
    }

    function setTreeData(string memory _color, string memory _shape, uint[] memory _berryAmount, uint[] memory _exp) public onlyOwner {
        require(_berryAmount.length == _exp.length, "Input wrong.");
        require(_exp[_exp.length - 1] == 0, "Max level tree is exp not 0.");

        for(uint i = 0; i < _berryAmount.length; i++) {
            treeDataId++;
            treeData[treeDataId] = TreeData(i + 1, _color, _shape, _berryAmount[i], _exp[i] * 10 ** 18, false);

            if(i == _berryAmount.length - 1) {
                treeData[treeDataId].isMaxLevel = true;
            }
        }
    }

    function setTokenURI(string memory _metadataURI) public onlyOwner {
        metadataURI = _metadataURI;
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        uint _treeDataId = trees[_tokenId];

        uint level = treeData[_treeDataId].level;
        string memory color = treeData[_treeDataId].color;
        string memory shape = treeData[_treeDataId].shape;

        return string(abi.encodePacked(metadataURI, '/', shape, '/', color, '/', Strings.toString(level), '.json'));
    }

    function getBerryAmount(uint _tokenId) public view returns(uint) {
        uint _treeDataId = trees[_tokenId];

        uint _berryAmount = treeData[_treeDataId].berryAmount;

        return _berryAmount;
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

    function levelUp(uint _tokenId) public treeOwner(_tokenId) {
        uint _treeDataId = trees[_tokenId];

        require(!treeData[_treeDataId].isMaxLevel, "Max level.");
        require(treeData[_treeDataId].exp <= berryContract.balanceOf(msg.sender), "Not enough berry.");

        berryContract.burnBerry(msg.sender, treeData[_treeDataId].exp);
        trees[_tokenId] = _treeDataId + 1;
    }
}