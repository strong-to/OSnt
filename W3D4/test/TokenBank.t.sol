// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";

import { TokenBank } from "../src/TokenBank.sol";

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import  "../src/SigUtils.sol";

import { MYERC2612 }  from  "../src/MYERC2612.sol";

contract CounterTest is Test {
    
        TokenBank public tokenBank;
        MYERC2612   public token;
        SigUtils public  sigUtils;
    
        uint256 public ownerPrivateKey;
        uint256 public spenderPrivateKey;

        address public owner;
        address public spender;
        address public alice;
    
    function setUp() public {

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        tokenBank = new TokenBank();
        token = new MYERC2612();

        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        token.transfer(owner, 5 * 1e18);

        alice = makeAddr("alice");

    }

    function test_depositWithPermit() public {

        SigUtils.Permit memory permit = SigUtils.Permit({

                    owner : owner,
                    spender : address(tokenBank),
                    value : 1e18,
                    nonce : token.nonces(owner),
                    deadline : block.timestamp + 3600 * 24
                    // deadline :block.timestamp + 3600 * 24
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        // 密钥ownerPrivateKey 和digest签名返回 (uint8 v, bytes32 r, bytes32 s) 这玩意又给到permit 去校验地址是否一致

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        uint256 bankBalance = token.balanceOf( address(spender) );
        uint256 ownerBalance = token.balanceOf(owner);

        // console.log("bank:", bankBalance, "  owner:", ownerBalance);
         
         tokenBank.depositWithPermit(
            permit.owner,
            address(token),
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );


        uint256 bankBalance2 = token.balanceOf(address(spender));
        uint256 ownerBalance2 = token.balanceOf(owner);

        console.log("bank2:", bankBalance2, "  owner2:", ownerBalance2);

        assertEq(bankBalance + 1e18, 1e18);
        assertEq(ownerBalance - 1e18, ownerBalance2);

    }
    /// 
    function test_notTokenBank() public {
        SigUtils.Permit memory permitNO = SigUtils.Permit({

                    owner : owner,
                    spender : alice, // 授权给非银行合约
                    value : 1e18,
                    nonce :0,
                    deadline :block.timestamp + 1 days
        });

        bytes32 digestNO = sigUtils.getTypedDataHash(permitNO);

        (uint8 vNO, bytes32 rNO, bytes32 sNO) = vm.sign(ownerPrivateKey, digestNO);
        

        // 授权错误 应该报错
        vm.expectRevert('NO NO NO NO NO NO ');

         tokenBank.depositWithPermit(
            permitNO.owner,
            address(token),
            permitNO.value,
            permitNO.deadline,
            vNO,
            rNO,
            sNO
        );
        
    }

}
