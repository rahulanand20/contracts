// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BCWARENFTV1 is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _collectbaleIds;
    Counters.Counter private _collectbaleAssetIds;
    address contractAddress;
    mapping(uint256 => string) public _collectableName;
    mapping(uint256 => string) public _collectableAssetName;
    mapping(uint256 => mapping(uint256 => string)) public _collectableAssetMap;

    struct ownerDetails {
        address owner;
        uint256 time;
    }
   
    mapping(uint256 => ownerDetails) public ownerHistory;
    uint256 createTime;

    mapping(string => uint256) public _uriToTokenId;

    constructor() ERC721("BCware NFT", "BCWTX") {}

    event CreateCollectable(uint256 _newCollectableId, string message);

    event CreateCollectableAsset(
        uint256 _newCollectableAssetId,
        string message
    );

    event TransactionDetails(
        uint256 _tokenId,
        string _blockchainNetwork,
        string _tokenURI,
        address _tokenOwner,
        uint256 _time,
        string _tokenStandard,
        string _mintFulfillment
    );
    event MintNFT(
        uint256 _newItemId,
        string chainName,
        string assetNameInEvent,
        string message
    );
    
    function mintNFT(
        string memory tokenURI,
        string memory collectableName,
        string memory assetName,
        address buyer
    ) public returns (uint256) {
       
        require(
            _uriToTokenId[tokenURI] == 0,
            "The URL already exists, kindly mint with a new URL."
        );

        _collectbaleIds.increment();
        uint256 newCollectableId = _collectbaleIds.current();
        _collectableName[newCollectableId] = collectableName;
        emit CreateCollectable(newCollectableId, "CreateCollectable");

        _collectbaleAssetIds.increment();
        uint256 newCollectableAssetId = _collectbaleAssetIds.current();
        _collectableAssetName[newCollectableAssetId] = assetName;
        _collectableAssetMap[newCollectableId][
            newCollectableAssetId
        ] = assetName;
        emit CreateCollectableAsset(
            newCollectableAssetId,
            "CreateCollectableAsset"
        );

        uint256 newItemId = newCollectableId * newCollectableAssetId;
        
        ownerHistory[newItemId] = ownerDetails(msg.sender, block.timestamp);

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _uriToTokenId[tokenURI] = newItemId;
        _transfer(msg.sender, buyer, newItemId);
        setApprovalForAll(contractAddress, true); 
        emit MintNFT(newItemId, "Ethereum", assetName, "CreateToken");
        return newItemId;
    }
}
