// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract GameFiRewards{

        function formMessage(bytes32 _message) public pure returns (bytes32)
    {
        bytes32 message = keccak256(abi.encodePacked(_message));
        return message;
    }

        function hashMessage(bytes32 message) internal pure returns (bytes32) {
            bytes memory prefix = "\x19Ethereum Signed Message:\n32";
            return keccak256(abi.encodePacked(prefix, message));
        }

        function recoverAddress(
        bytes32 message,
        bytes memory signature
    ) internal pure returns (address) {
        if (signature.length != 65) {
            revert("invalid signature length");
        }
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return getSigner(message, v, r, s);
    }

        function getSigner(
        bytes32 message, 
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {  
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "invalid signature 's' value");
        require(v == 27 || v == 28, "invalid signature 'v' value");
        address signer = ecrecover(hashMessage(message), v, r, s);
        require(signer != address(0), "invalid signature");

        return signer;
    }
}