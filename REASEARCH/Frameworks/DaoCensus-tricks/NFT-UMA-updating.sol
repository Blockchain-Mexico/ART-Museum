// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.16;

import 'protocol/packages/core/contracts/oracle/interfaces/OptimisticOracleV2Interface.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol';
import './DAOCensus.sol';

contract umaInteract is DAOCensus {
    // Other code ...

    IERC721 public nftContract;
    IERC721Metadata public nftMetadata;

    // Add nftContractAddress to the constructor
    constructor(
        address DAOaddress,
        uint16 limit,
        uint256 payment,
        address nftContractAddress
    ) public {
        // Other constructor code ...

        // Initialize nftContract and nftMetadata with the given address
        nftContract = IERC721(nftContractAddress);
        nftMetadata = IERC721Metadata(nftContractAddress);
    }

    // Add a new function to update NFT metadata based on the Optimistic Oracle's decision
    function updateNFTMetadata(uint256 tokenId, string memory newUri, string memory IPFSHash) public {
        // Check if the request has been settled and the result is 0 (accepted)
        if (lastDeploymentProposal[IPFSHash].time != 0 && getSettledData(IPFSHash) == 0) {
            // Ensure that the caller is the owner of the NFT
            require(nftContract.ownerOf(tokenId) == msg.sender, "Caller must be the NFT owner");

            // Check if the NFT contract supports the setTokenURI function (IERC721Metadata)
            bool supportsSetTokenUri = nftContract.supportsInterface(type(IERC721Metadata).interfaceId);

            // Update the NFT's metadata if the setTokenURI function is supported
            if (supportsSetTokenUri) {
                nftMetadata.setTokenURI(tokenId, newUri);
            }
        }
    }

    // Other code ...
}
