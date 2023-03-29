// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.16;

import "./DAOCensus.sol";
import "./NFTMetadataUpdateOracle.sol";
import "./NFTMetadataUpdateVoting.sol";

interface INFTMetadataUpdateOracle {
    function requestData(bytes memory ancillaryData) external;
    function settleRequest(bytes memory ancillaryData) external;
    function getSettledData(bytes memory ancillaryData) external view returns (int256);
}

interface INFTMetadataUpdateVoting {
    function createProposal(uint256 tokenId, string memory IPFSHash) external;
    function updateProposal(string memory IPFSHash, NFTMetadataUpdateVoting.State newState) external;
    function getProposalQuestion(string memory IPFSHash) external view returns (bytes memory);
    function applyMetadataUpdate(uint256 tokenId, string memory IPFSHash) external;
}

contract NFTMetadataUpdateCoordinator {
    INFTMetadataUpdateOracle public oracle;
    INFTMetadataUpdateVoting public voting;

    constructor(address _oracleAddress, address _votingAddress) {
        oracle = INFTMetadataUpdateOracle(_oracleAddress);
        voting = INFTMetadataUpdateVoting(_votingAddress);
    }

    function createProposal(uint256 tokenId, string memory IPFSHash) public {
        voting.createProposal(tokenId, IPFSHash);
    }

    function requestData(string memory IPFSHash) public {
        bytes memory ancillaryData = voting.getProposalQuestion(IPFSHash);
        oracle.requestData(ancillaryData);
    }

    function settleRequest(string memory IPFSHash) public {
        bytes memory ancillaryData = voting.getProposalQuestion(IPFSHash);
        oracle.settleRequest(ancillaryData);
        int256 result = oracle.getSettledData(ancillaryData);

        NFTMetadataUpdateVoting.State newState = NFTMetadataUpdateVoting.State.REFUSED;
        if (result == 0) newState = NFTMetadataUpdateVoting.State.ACCEPTED;

        voting.updateProposal(IPFSHash, newState);
    }

    function applyMetadataUpdate(uint256 tokenId, string memory IPFSHash) public {
        voting.applyMetadataUpdate(tokenId, IPFSHash);
    }
}
