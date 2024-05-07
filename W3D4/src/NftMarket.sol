// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";
contract NFTMarket is IERC721Receiver , Nonces {
    mapping(uint => uint) public tokenIdPrice;
    mapping(uint => address) public tokenSeller;

    address public immutable token;
    address public immutable nftToken;
    address admin;

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32; 
    constructor(address _token, address _nftToken) {
        token = _token;
        nftToken = _nftToken;
        admin = msg.sender;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function list(uint tokenId, uint amount) public {
        IERC721(nftToken).safeTransferFrom(msg.sender, address(this), tokenId, "");
        tokenIdPrice[tokenId] = amount;
        tokenSeller[tokenId] = msg.sender;
    }

    function buy(uint tokenId, uint amount) public {
        require(amount >= tokenIdPrice[tokenId], "Insufficient payment amount");
        require(IERC721(nftToken).ownerOf(tokenId) == address(this), "NFT not available");
        IERC20(token).transferFrom(msg.sender, tokenSeller[tokenId], tokenIdPrice[tokenId]);
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
    }

    function permitBuy(
        uint256 nonce,
        bytes calldata signature,
        uint256 tokenId,
        uint256 amount
        
    ) external {

        _useCheckedNonce(msg.sender, nonce); // 检查msg.sender 的nonce 和当前nonce是否一致

        // hash运算，购买者的地址 tokenId 金额 进行编码计算hash
        bytes32 hash = keccak256(abi.encodePacked(msg.sender,nonce));  
        
        hash = hash.toEthSignedMessageHash();
        // 解析出签名地址
        address recoveredSigner = hash.recover(signature); //recover根据内容 解析出签名者的地址

        require(recoveredSigner == admin, 'not admin');

        _useNonce(msg.sender); //

        buy(tokenId,amount);

    }
}
