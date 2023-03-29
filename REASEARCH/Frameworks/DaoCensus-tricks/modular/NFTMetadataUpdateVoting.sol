// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "./DAOCensus.sol";

contract NFTMetadataUpdateVoting is DAOCensus {
    IERC721Metadata public nftContract;

    enum State {NONE, SUBMITTED, VOTE_ONGOING, ACCEPTED, REFUSED}

    struct Proposal {
        State state;
        uint256 timestamp;
        bytes ancillaryData;
    }

    mapping(string => Proposal) public proposals;

    event ProposalCreated(string IPFSHash, State state);
    event ProposalUpdated(string IPFSHash, State state);

    constructor(address _nftContractAddress) {
        nftContract = IERC721Metadata(_nftContractAddress);
    }

    function createProposal(uint256 tokenId, string memory IPFSHash) public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Only the NFT owner can create a proposal.");
        proposals[IPFSHash] = Proposal(State.SUBMITTED, block.timestamp, bytes(""));
        emit ProposalCreated(IPFSHash, State.SUBMITTED);
    }

    function updateProposal(string memory IPFSHash, State newState) public {
        proposals[IPFSHash].state = newState;
        emit ProposalUpdated(IPFSHash, newState);
    }

    function getProposalQuestion(string memory IPFSHash) public view returns (bytes memory) {
        return bytes(string.concat(IPFSHash, ' : 0 to accept this metadata update - else 1 '));
    }

    function applyMetadataUpdate(uint256 tokenId, string memory IPFSHash) public {
        require(proposals[IPFSHash].state == State.ACCEPTED, "Metadata update has not been accepted.");
        require(nftContract.ownerOf(tokenId) == msg.sender, "Only the NFT owner can apply the metadata update.");
        nftContract.updateMetadata(tokenId, IPFSHash);
        emit MetadataUpdated(tokenId, IPFSHash);
    }
}
