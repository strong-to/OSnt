// SPDX-License-Identifier: UNLICENSED
pragma solidity  ^0.8.2;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import "../src/NftMarket.sol";
import { ERC721Mock } from './mock/ERC721mock.sol';
import { BaseERC20 } from '../src/BaseERC20.sol';
import {ECDSA} from "../lib/./openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils} from "../lib/./openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract NFTMarketTest is Test {
    
    NFTMarket  nftmkt;

    ERC721Mock nft; // mint
    BaseERC20 ercToken ;

    address alice = makeAddr('alice'); // 地址

    // using ECDSA for bytes32;
    // using MessageHashUtils for bytes32;

    address admin;
    uint256 adminKey;
    // 初始化要有nft
    function setUp() public {

         (admin, adminKey) = makeAddrAndKey("admin"); // 地址和密钥

          vm.startPrank(admin);
        //   vm.startPrank(alice) ;
          nft = new ERC721Mock();
          ercToken = new BaseERC20();

          nftmkt = new NFTMarket(address(ercToken) , address(nft) );

          vm.stopPrank();

    } 

    function test_permitBuy() public {

        address alice = makeAddr('alice');

        nft.mint();
        nft.approve(address(nftmkt), 0);
         
        nftmkt.list(0, 100);

        //项目方admin对alice签名，使用sign方法， 密钥签名处理，通过recover解密出对应的地址校验
        vm.startPrank(admin); 
        ercToken.transfer(alice, 100);
        bytes32 hash = keccak256(abi.encodePacked(alice, uint256(0))); // 计算hash
        hash = MessageHashUtils.toEthSignedMessageHash(hash);          // 转化成以太坊标准hash
        // 用管理员密钥对hash进行签名 生成 v、r、s 这三个签名参数。
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(adminKey, hash);   
        bytes memory sig = abi.encodePacked(r, s, v);  //将签名参数 v、r、s 编码成字节序列，准备用于签名验证。
        vm.stopPrank();

        vm.startPrank(alice);

        uint256 bal =  ercToken.balanceOf(alice);
       
        ercToken.approve(address(nftmkt), 100);

        nftmkt.permitBuy(0, sig, 0, 100);

        assertEq(ercToken.balanceOf(alice), 0);
        assertEq(nft.balanceOf(alice), 1);
        console.log(ercToken.balanceOf(alice));

    }

}