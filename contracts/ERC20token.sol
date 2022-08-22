// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SampleERC20
 * @dev Create a sample ERC20 standard token
 */
contract SampleERC20 is ERC20,Ownable {
    constructor() ERC20("BenCoin", "BEN") {}
    function mint(address _account,uint _amount) public onlyOwner{
        _mint(_account,_amount);
    }
}