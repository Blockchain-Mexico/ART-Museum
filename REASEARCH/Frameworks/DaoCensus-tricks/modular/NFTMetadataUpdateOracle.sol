// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import 'protocol/packages/core/contracts/oracle/interfaces/OptimisticOracleV2Interface.sol';
import "./DAOCensus.sol";

contract NFTMetadataUpdateOracle {
    OptimisticOracleV2Interface oo = OptimisticOracleV2Interface(0xA5B9d8a0B0Fa04Ba71BDD68069661ED5C0848884);

    bytes32 identifier = bytes32('YES_OR_NO_QUERY');

    function requestData(bytes memory ancillaryData) public {
        uint256 requestTime = block.timestamp;
        IERC20 bondCurrency = IERC20(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
        uint256 reward = 0;
        oo.requestPrice(identifier, requestTime, ancillaryData, bondCurrency, reward);
        oo.setCustomLiveness(identifier, requestTime, ancillaryData, 30);
    }

    function settleRequest(bytes memory ancillaryData) public {
        uint256 requestTime = block.timestamp;
        oo.settle(address(this), identifier, requestTime, ancillaryData);
    }

    function getSettledData(bytes memory ancillaryData) public view returns (int256) {
        uint256 requestTime = block.timestamp;
        return oo.getRequest(address(this), identifier, requestTime, ancillaryData).resolvedPrice;
    }
}
