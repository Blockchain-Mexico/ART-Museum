// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AINFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Census {
        uint256 population;
        uint256 revenue;
        uint256 funding;
    }

    mapping(uint256 => Census) private _tokenCensus;

    constructor() ERC721("AI NFT", "AINFT") {}

    function mintNFT(string memory tokenURI, uint256 population, uint256 revenue, uint256 funding)
        public
        onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(owner(), newItemId);
        _setTokenURI(newItemId, tokenURI);
        _addCensus(newItemId, population, revenue, funding);

        return newItemId;
    }

    function getCensus(uint256 tokenId) public view returns (Census memory) {
        return _tokenCensus[tokenId];
    }

    function _addCensus(uint256 tokenId, uint256 population, uint256 revenue, uint256 funding) private {
        _tokenCensus[tokenId] = Census({
            population: population,
            revenue: revenue,
            funding: funding
        });
    }
}
