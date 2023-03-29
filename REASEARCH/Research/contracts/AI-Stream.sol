// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StreamNFT is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    mapping(uint256 => string) private _tokenStreams;

    constructor() ERC721("Stream NFT", "SNFT") {}

    function mintStreamNFT(address to, string memory tokenURI, string memory streamURL) public onlyOwner returns (uint256) {
        _tokenIdCounter = _tokenIdCounter + 1;
        uint256 tokenId = _tokenIdCounter;
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _tokenStreams[tokenId] = streamURL;

        return tokenId;
    }

    function getStreamURL(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token ID does not exist");
        return _tokenStreams[tokenId];
    }
}
