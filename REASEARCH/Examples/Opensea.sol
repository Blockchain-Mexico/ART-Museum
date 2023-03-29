pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.0/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.0/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.0/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.0/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./IERC2981.sol";

// Import OpenSea SDK
import "@opensea/sdk";

contract MyNFT is ERC721URIStorage, Ownable, IERC2981 {
    using Counters for Counters.Counter;
    using Address for address payable;

    Counters.Counter private _tokenIdCounter;

    // OpenSea SDK variables
    address private _owner;
    address private _proxyRegistryAddress;

    constructor(address proxyRegistryAddress) ERC721("MyNFT", "MNFT") {
        _owner = msg.sender;
        _proxyRegistryAddress = proxyRegistryAddress;
    }

    // Override the _baseURI() function to return the base URI of your NFTs
    function _baseURI() internal view override returns (string memory) {
        return "https://example.com/token/";
    }

    // Override the tokenURI() function to return the URI of a specific token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
        return string(abi.encodePacked(_baseURI(), tokenId.toString()));
    }

    // Override the safeTransferFrom() function to add support for the OpenSea proxy registry
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        // Call the original safeTransferFrom function
        super.safeTransferFrom(from, to, tokenId, _data);

        // Check if the recipient is a valid OpenSea proxy address
        _checkOnOpenSeaRegistry(to);

        // If the transfer was successful and the recipient is a valid OpenSea proxy address, emit the transfer event
        emit TransferWithPayment(from, to, tokenId, msg.value, _data);
    }

    // Override the transferFrom() function to add support for the OpenSea proxy registry
    function transferFrom(address from, address to, uint256 tokenId) public override {
        // Call the original transferFrom function
        super.transferFrom(from, to, tokenId);

        // Check if the recipient is a valid OpenSea proxy address
        _checkOnOpenSeaRegistry(to);

        // If the transfer was successful and the recipient is a valid OpenSea proxy address, emit the transfer event
        emit TransferWithPayment(from, to, tokenId, 0, "");
    }

    // Override the safeTransferFrom() function to add support for the OpenSea proxy registry
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        // Call the original safeTransferFrom function
        super.safeTransferFrom(from, to, tokenId);

     // Check if the recipient is a valid OpenSea proxy address
     _checkOnOpenSeaRegistry(to);
 }
