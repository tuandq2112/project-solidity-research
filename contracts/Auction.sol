// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Auction {

    uint256 private itemCount = 0; 

    struct Item {
        uint itemId;
        uint tokenId;
        uint startingPrice;
        address seller;
        uint256 auctionTime;
        bool isSold;
        bool endTime;
        uint256 numberOfBidders;
        address addressOfPriceHighest;
    }

    // address to price
    mapping(address => uint256) private addressToPrice;

    // itemId -> Item
    mapping(uint256 => Item) private items;


    IERC721 private nft;
    IERC20 private token;

    
    constructor(IERC721 _nft, IERC20 _token) {
        nft = _nft;
        token = _token;
    }

    // Make item to auction one nft on the marketplace
    function makeItem(uint256 _tokenId, uint256 _price, uint256 _time) public {
        // increment itemCount
        itemCount ++;
        // transfer nft
        nft.transferFrom(msg.sender, address(this), _tokenId);
        // add new item to items mapping
        items[itemCount] = Item (
            itemCount,
            _tokenId,
            _price,
            msg.sender,
            (block.timestamp + _time),
            false,
            false,
            0,
            msg.sender
        );
        addressToPrice[msg.sender] = _price;
    }

    /*
    * @ check the conditions are satisfied can start depositing
    */
    modifier canBidAuction(uint256 _itemId) {
        Item storage item = items[_itemId];
        require(item.itemId != 0, "item does not exist");
        require (block.timestamp < item.auctionTime, "deposit timeout");
        require(item.isSold == false, "the item has been sold");

        _;
    }

    /*
    @dev
    function Set the price that the bidder wants to bid
    */
    function bidAuction(uint256 _itemId, uint256 _amounts) public canBidAuction(_itemId) returns(address, uint256) {
        
        Item storage item = items[_itemId];
        // current highest price
        uint256 priceHighest = addressToPrice[item.addressOfPriceHighest];
        
        require(token.allowance(msg.sender, address(this)) >= _amounts, "not enough approve tokens");
        require(_amounts > priceHighest, "_amounts must be greater than current highest price");

        // transfer token to the previous auctioneer
        if(item.numberOfBidders != 0) {
            token.transfer(item.addressOfPriceHighest, priceHighest);    
        }
        // increment number Of Bidders
        item.numberOfBidders ++;

        //reset price and address of the person, who have the highest price
        item.addressOfPriceHighest = msg.sender;
        addressToPrice[msg.sender] = _amounts;
        token.transferFrom(msg.sender, address(this), _amounts);

        return (msg.sender, _amounts);
    }

    /*
    @dev complete the auction
    */
    function completeAuction(uint256 itemId) public {
        Item storage item = items[itemId];
        require (block.timestamp > item.auctionTime, "Auction is still in progress");

        // current highest price
        uint256 priceHighest = addressToPrice[item.addressOfPriceHighest];
        
        // There is a successful bidder
        if(item.numberOfBidders != 0) {
            token.transfer(item.seller, priceHighest);
            nft.transferFrom(address(this), item.addressOfPriceHighest, item.tokenId);
        } 
        // noone participates in the auction
        else {
            nft.transferFrom(address(this), item.addressOfPriceHighest, item.tokenId);
        }
        // item sold
        item.isSold = true;
        // time auction ended
        item.endTime = true;
    }

    /*
    @dev return current highest price 
    */
    function getPriceHighestCurrent(uint256 itemId) public view returns(uint256) {
        Item storage item = items[itemId];
        return addressToPrice[item.addressOfPriceHighest];
    }

    function showInfoItem(uint256 _itemId) public view returns(Item memory) {
        return items[_itemId];
    }

    
}