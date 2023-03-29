// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CollabNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => address[]) private _tokenCollaborators;

    constructor() ERC721("Collab NFT", "CNFT") {}

    function mintNFT(address[] memory collaborators, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(owner(), newItemId);
        _setTokenURI(newItemId, tokenURI);
        _addCollaborators(newItemId, collaborators);

        return newItemId;
    }

    function addCollaborators(uint256 tokenId, address[] memory collaborators) public {
        require(_exists(tokenId), "Token ID does not exist");
        require(ownerOf(tokenId) == _msgSender(), "Not token owner");
        _addCollaborators(tokenId, collaborators);
    }

    function getCollaborators(uint256 tokenId) public view returns (address[] memory) {
        return _tokenCollaborators[tokenId];
    }

    function _addCollaborators(uint256 tokenId, address[] memory collaborators) private {
        for (uint256 i = 0; i < collaborators.length; i++) {
            address collaborator = collaborators[i];
            if (!_isCollaborator(tokenId, collaborator)) {
                _tokenCollaborators[tokenId].push(collaborator);
            }
        }
    }

    function _isCollaborator(uint256 tokenId, address collaborator) private view returns (bool) {
        for (uint256 i = 0; i < _tokenCollaborators[tokenId].length; i++) {
            if (_tokenCollaborators[tokenId][i] == collaborator) {
                return true;
            }
        }
        return false;
    }
}
