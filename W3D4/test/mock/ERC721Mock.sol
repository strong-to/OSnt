// //SPDX-License-Identifier: MIT
pragma solidity  0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721Mock is ERC721 {

    uint256 count = 0;
    constructor() ERC721("MyERC721", "MyERC721") {}

    // using ECDSA for bytes32;
    // using MessageHashUtils for bytes32;

    function mint() public {
        _mint(msg.sender, count++);
    }
}