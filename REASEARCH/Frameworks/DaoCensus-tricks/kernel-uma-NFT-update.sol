// SPDX-License-Identifier: AGPL-3.0-only
// The code above incorporates the Optimistic Oracle and DAO voting mechanism from the `umaInteract` contract into the `NFTMetadataUpdateKernel` contract. The NFT owners can now create proposals for metadata updates, request data from the Optimistic Oracle, and settle the requests. After the voting process, if the metadata update is accepted, the NFT owners can apply the metadata update to their NFTs.

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import 'protocol/packages/core/contracts/oracle/interfaces/OptimisticOracleV2Interface.sol';
import "./DAOCensus.sol";

contract NFTMetadataUpdateKernel is DAOCensus {
    IERC721Metadata public nftContract;

    OptimisticOracleV2Interface oo = OptimisticOracleV2Interface(0xA5B9d8a0B0Fa04Ba71BDD68069661ED5C0848884);

    bytes32 identifier = bytes32('YES_OR_NO_QUERY');
    uint256 public requestTime = 0;

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
        requestData(IPFSHash);
    }

    function requestData(string memory IPFSHash) public {
        bytes memory ancillaryData = getProposalQuestion(IPFSHash);
        requestTime = block.timestamp;
        IERC20 bondCurrency = IERC20(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
        uint256 reward = 0;
        oo.requestPrice(identifier, requestTime, ancillaryData, bondCurrency, reward);
        oo.setCustomLiveness(identifier, requestTime, ancillaryData, 30);
        proposals[IPFSHash].state = State.VOTE_ONGOING;
        proposals[IPFSHash].ancillaryData = ancillaryData;
        emit ProposalUpdated(IPFSHash, State.VOTE_ONGOING);
    }

    function getProposalQuestion(string memory IPFSHash) internal pure returns (bytes memory) {
        return bytes(string.concat(IPFSHash, ' : 0 to accept this metadata update - else 1 '));
    }

    function settleRequest(string memory IPFSHash) public {
        oo.settle(address(this), identifier, requestTime, proposals[IPFSHash].ancillaryData);
        int256 result = getSettledData(IPFSHash);
        State newState = State.REFUSED;
        if (result == 0) newState = State.ACCEPTED;
        proposals[IPFSHash].state = newState;
        emit ProposalUpdated(IPFSHash, newState);
    }

    function getSettledData(string memory IPFSHash) public view returns (int256) {
        return oo.getRequest(address(this), identifier, requestTime, proposals[IPFSHash].ancillaryData).resolvedPrice;
    }

    function applyMetadataUpdate(uint256 tokenId, string memory IPFSHash) public {
        require(proposals[IPFSHash].state == State.ACCEPTED, "Metadata update has not been accepted.");
               require(nftContract.ownerOf(tokenId) == msg.sender, "Only the NFT owner can apply the metadata update.");
                   nftContract.updateMetadata(tokenId, IPFSHash);

                   emit MetadataUpdated(tokenId, IPFSHash);
               }
               }

               interface INFTMetadataUpdate {
               function updateMetadata(uint256 tokenId, string memory IPFSHash) external;
               }

               contract NFTMetadataUpdate is IERC721Metadata, INFTMetadataUpdate {
               using Strings for uint256;
               string private _baseURI;

               mapping(uint256 => string) private _tokenURIs;

               constructor(string memory baseURI_) {
                   _baseURI = baseURI_;
               }

               function updateMetadata(uint256 tokenId, string memory IPFSHash) external override {
                   require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
                   _tokenURIs[tokenId] = IPFSHash;
               }

               function name() public view virtual override returns (string memory) {
                   return "MyNFT";
               }

               function symbol() public view virtual override returns (string memory) {
                   return "MNFT";
               }

               function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
                   require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

                   string memory _tokenURI = _tokenURIs[tokenId];
                   string memory base = _baseURI();

                   return bytes(_tokenURI).length > 0 ? string(abi.encodePacked(base, _tokenURI)) : "";
               }

               function _baseURI() internal view virtual returns (string memory) {
                   return _baseURI;
               }

               function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
                   require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
                   _tokenURIs[tokenId] = _tokenURI;
               }

               function _setBaseURI(string memory baseURI_) internal virtual {
                   _baseURI = baseURI_;
               }

}


