
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DuongTOKEN is ERC20, Ownable {
  
    constructor() ERC20("DuongToken", "DTK") {
    }

    /*
    @mint token cho account
    */
    function mintToken(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    /*
    @ uy quyen amounts token cho spender
    */
    function approveToken(address spender, uint256 amounts) public {
        approve(spender, amounts);
    }     

    /*
    @ kiem tra so token ma owner uy quyen cho spender
    */
    function checkAllowance(address owner, address spender) public view returns(uint256) {
        uint256 amounts = allowance(owner, spender);
        return amounts;
    }

    /*
    @ chuyen so token duoc uy quyen
    */
    function transferFromToken(address from, address to, uint256 amounts) public {
        transferFrom(from, to, amounts);
    }

    /*
    @ kiem tra so token cua owner
    */
    function checkBalanceOf(address owner) public view returns(uint256) {
        uint256 amounts = balanceOf(owner);
        return amounts;
    }




   

  
}