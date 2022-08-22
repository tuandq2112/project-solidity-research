// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DUONGNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIds;

    constructor() public ERC721("DuongNFT", "DNFT") {}


    /*
    @ tao nft moi
    */
    function createNFT(address owner, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    /*
    @ uy quyen nft
    */
    function approveNFT(address to, uint256 tokenId) public {
        approve(to, tokenId);
    }

    /*
    @ chuyen quyen so huu nft tu from sang to
    */
    function transferFromNFT(address from, address to, uint256 tokenId) public {
        transferFrom(from, to, tokenId);
    }

    /*
    @ kiem tra tokenId ma owner so huu
    */
    function balanceOfNFT(address owner) public view returns(uint256) {
        return balanceOf(owner);
    }

    /*
    @ kiem tra dia chi so huu cua tokenId
    */
    function ownerOfNFT(uint256 tokenId) public view returns(address) {
        return ownerOf(tokenId);
    }

}