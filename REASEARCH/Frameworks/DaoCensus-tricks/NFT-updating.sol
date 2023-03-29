// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.16;

import 'protocol/packages/core/contracts/oracle/interfaces/OptimisticOracleV2Interface.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import './DAOCensus.sol';

contract umaInteract is DAOCensus {
    // ... (previous code)

    IERC721 public nftContract;

    constructor(address nftContractAddress) {
        nftContract = IERC721(nftContractAddress);
    }

    // ... (previous code)

    function updateNFT(uint256 tokenId, string memory IPFSHash) public {
        // Check if the message sender is the owner of the token
        require(nftContract.ownerOf(tokenId) == msg.sender, "Caller must be the owner of the NFT.");

        // Update NFT metadata
        // Note: This assumes that the NFT contract has a setTokenURI function
        // If it doesn't, you may need to implement a different strategy for updating the NFT metadata
        nftContract.setTokenURI(tokenId, IPFSHash);

        // Emit an event
        emit NFTUpdated(tokenId, IPFSHash);
    }

    // Add event for NFT update
    event NFTUpdated(uint256 indexed tokenId, string IPFSHash);
}
