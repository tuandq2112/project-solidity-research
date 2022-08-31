// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VerifyMessageAndReward is Ownable {

    IERC20 private token;

    address private addrPubServer;

    //@dev address => times => bool
    // return false => unused coupons
    // return true => used coupons
    mapping(address => mapping(uint256 => bool)) statusCoupon;

    constructor(address _token, address _signer) {
        token = IERC20(_token);
        addrPubServer = _signer;
    }

    // function setSigner(address _signer) public onlyOwner {
    //     addrPubServer = _signer;
    // }

    function checkStatusCoupon(address add, uint256 time) public view returns(bool) {
        return statusCoupon[add][time];
    }

    //@dev convert string to uint
    function stringToUint(string memory s) private pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    //@dev check signer of mess == addrPubServer
    modifier checkSigner(
        address player, 
        string memory amount, 
        string memory timestamp, 
        bytes memory signature) {
            bytes32 check = hashMessage(player, amount, timestamp);
            require(ecrecoverMessage(check, signature) == addrPubServer, "unauthenticated message");

            _;
    }

    modifier isUsedCoupons(address addr, string memory couponReleaseTime) {
        uint256 time = stringToUint(couponReleaseTime);
        require(statusCoupon[addr][time] == false, "coupon already used");
        _;
    }

    //@dev convert signature to (r,s,v)
    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    //@dev hash message with EIP-191 
    function hashMessage(address player, string memory amount, string memory timestamp) isUsedCoupons(player, timestamp) private returns (bytes32) {
        
        //convert addr of player to string
        string memory addr = Strings.toHexString(uint256(uint160(player)), 20);

        // Combine the addrPlayer, amounts, timestamp fields into a single string
        string memory message = string(bytes.concat(bytes(addr),bytes(amount),bytes(timestamp)));

        // The message header; we will fill in the length next
        string memory header = "\x19Ethereum Signed Message:\n000000";

        uint256 lengthOffset;
        uint256 length;
        assembly {
            // The first word of a string is its length
            length := mload(message)
            // The beginning of the base-10 message length in the prefix
            lengthOffset := add(header, 57)
        }

        // Maximum length we support
        require(length <= 999999);

        // The length of the message's length in base-10
        uint256 lengthLength = 0;

        // The divisor to get the next left-most message length digit
        uint256 divisor = 100000;

        //convert and encode message (according to keccak256) to bytes32
        while (divisor != 0) {

            // The place value at the divisor
            uint256 digit = length / divisor;
            if (digit == 0) {
                // Skip leading zeros
                if (lengthLength == 0) {
                    divisor /= 10;
                    continue;
                }
            }

            // Found a non-zero digit or non-leading zero digit
            lengthLength++;

            // Remove this digit from the message length's current value
            length -= digit * divisor;

            // Shift our base-10 divisor over
            divisor /= 10;

            // Convert the digit to its ASCII representation (man ascii)
            digit += 0x30;
            // Move to the next character and write the digit
            lengthOffset++;

            assembly {
                mstore8(lengthOffset, digit)
            }
        }

        // The null string requires exactly 1 zero (unskip 1 leading 0)
        if (lengthLength == 0) {
            lengthLength = 1 + 0x19 + 1;
        } else {
            lengthLength += 1 + 0x19;
        }

        // Truncate the tailing zeros from the header
        assembly {
            mstore(header, lengthLength)
        }

        // encodePacked header("\x19Ethereum Signed Message:\n000000") and mess(bytes32) 
        // after encode with keccak256
        bytes32 check = keccak256(abi.encodePacked(header, message));
        return check;
    }

    function ecrecoverMessage(bytes32 hashMess, bytes memory signature) public returns(address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(hashMess, v, r, s);
    }

    //@dev reward token after verify
    function rewardToken(
        address player, 
        string memory amount, 
        string memory timestamp, 
        bytes memory signature) 
        public 
        checkSigner(player, amount, timestamp, signature) {
        
        uint256 amountsTokenReward = stringToUint(amount);
        uint256 timestampUint = stringToUint(timestamp);

        statusCoupon[player][timestampUint] = true;
        
        require(token.balanceOf(address(this)) >= amountsTokenReward, "not enough tokens to reward");

        token.transfer(player, amountsTokenReward);
    }

}