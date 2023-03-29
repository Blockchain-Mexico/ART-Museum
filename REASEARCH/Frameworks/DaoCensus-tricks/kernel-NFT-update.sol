// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

contract NFTMetadataUpdateKernel {
    IERC721Metadata public nftContract;

    enum State {NONE, SUBMITTED, VOTE_ONGOING, ACCEPTED, REFUSED}

    struct Proposal {
        State state;
        uint256 timestamp;
    }

    mapping(string => Proposal) public proposals;

    event ProposalCreated(string IPFSHash, State state);
    event ProposalUpdated(string IPFSHash, State state);

    constructor(address _nftContractAddress) {
        nftContract = IERC721Metadata(_nftContractAddress);
    }

    function createProposal(uint256 tokenId, string memory IPFSHash) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Only the NFT owner can create a proposal.");
        proposals[IPFSHash] = Proposal(State.SUBMITTED, block.timestamp);
        emit ProposalCreated(IPFSHash, State.SUBMITTED);
    }

    function updateProposalState(string memory IPFSHash, State newState) public {
        require(proposals[IPFSHash].state != State.NONE, "Proposal not found.");
        proposals[IPFSHash].state = newState;
        emit ProposalUpdated(IPFSHash, newState);
    }

    function applyMetadataUpdate(uint256 tokenId, string memory IPFSHash) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Only the NFT owner can apply metadata updates.");
        require(proposals[IPFSHash].state == State.ACCEPTED, "The proposal must be accepted to apply the update.");
        nftContract.updateTokenURI(tokenId, IPFSHash);
    }
}
