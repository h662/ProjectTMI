// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Tree.sol";

contract Ground is ERC721Enumerable, Ownable {
    struct GroundData {
        string groundName;
        uint groundSize;
        uint startGroundId;
        uint endGroundId;
    }

    mapping(uint => uint) grounds;
    mapping(uint => GroundData) groundData;

    mapping(uint => uint) public plantedTreeId;

    mapping(uint => string) metadataUri;

    address treeAddress;
    Tree treeContract;

    uint groundDataId;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    modifier isTransferable(uint _tokenId) {
        require(plantedTreeId[_tokenId] == 0, "Already planted.");
        _;
    }

    function mintGrounds(string memory _groundName, uint _groundSize, string memory _metadataUri) public onlyOwner {
        groundDataId++;
        uint _startGroundId = totalSupply() + 1;
        uint _endGroundId = totalSupply() + _groundSize;

        for(uint i = 0; i < _groundSize; i++) {
            uint _tokenId = totalSupply() + 1;

            _mint(msg.sender, _tokenId);
            grounds[_tokenId] = groundDataId;
        }
        
        groundData[groundDataId] = GroundData(_groundName, _groundSize, _startGroundId, _endGroundId);

        metadataUri[groundDataId] = _metadataUri;
    }

    function tokenURI(uint _tokenId) public override view returns(string memory) {
        uint _groundDataId = grounds[_tokenId];

        return metadataUri[_groundDataId];
    }

    function plantTree(uint _tokenId, uint _treeId) public {
        require(msg.sender == ownerOf(_tokenId), "U R not ground owner.");
        require(plantedTreeId[_tokenId] == 0, "Already planted.");

        treeContract.plantTree(msg.sender, _treeId);

        plantedTreeId[_tokenId] = _treeId;
    }

    function popTree(uint _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "U R not ground owner.");
        require(plantedTreeId[_tokenId] != 0, "Not planted");

        uint _treeId = plantedTreeId[_tokenId];

        treeContract.popTree(msg.sender, _treeId);

        plantedTreeId[_tokenId] = 0;
    }

    function setTreeContract(address _treeAddress) public onlyOwner {
        treeAddress = _treeAddress;
        treeContract = Tree(_treeAddress);
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