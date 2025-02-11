//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lib//openzeppelin-contracts/contracts/utils/Address.sol";

import "../lib//openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

interface TokenRecipient {
    function tokensReceived(address sender, uint amount) external returns (bool);
}

contract MYERC2612 is ERC20Permit {
    using Address for address;

    constructor() ERC20("tuwenchu", "tg") ERC20Permit("ERC2612") {
        _mint(msg.sender, 2612 * 10 ** 18);
    }

    function transferWithCallback(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);

        if (recipient.code.length > 0) {
            bool rv = TokenRecipient(recipient).tokensReceived(msg.sender, amount);
            require(rv, "No tokensReceived");
        }

        return true;
    }
    
}