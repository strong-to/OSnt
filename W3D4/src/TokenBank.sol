// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseERC20.sol";
interface IERC20Permit {  
    function permit(  
        address owner,  
        address spender,  
        uint256 value,  
        uint256 deadline,  
        uint8 v,  
        bytes32 r,  
        bytes32 s  
    ) external;  
}
// TokenBank 合约用于存储用户的 Token，并提供存款和取款功能
contract TokenBank {

    //  用户的地址。合约的地址 
    mapping(address => mapping(address => uint256)) public TokenBalances;

    // 存款函数，用户可以将 Token 存入 TokenBank 合约
    function deposit(address token, uint256 _value) public {

        BaseERC20 ERC20 = BaseERC20(token);

        ERC20.transferFrom(msg.sender, address(this), _value);
        
        TokenBalances[token][msg.sender] += _value;
    }
    

    // 取款函数，用户可以从 TokenBank 合约取回存入的 Token
    function withdraw(address token, uint256 _value) public {

        require(_value <= TokenBalances[token][msg.sender], "withdraw amount exceeds balance");

        // 创建 BaseERC20 类型的实例
        BaseERC20 ERC20 = BaseERC20(token);

        ERC20.transfer(address(msg.sender), _value);
        
        TokenBalances[token][msg.sender] -= _value;
    }
    
    // 修改 TokenBank 存款合约 ,添加一个函数 permitDeposit 以支持离线签名授权（permit）进行存款。
    function depositWithPermit(  
      address user,
      address token,  
      uint256 _value,  
      uint256 deadline,  
      uint8 v,  
      bytes32 r,  
      bytes32 s  
    ) public {  
        IERC20Permit ERC20Permit = IERC20Permit(token);    
        // 使用 permit 方法授权 TokenBank 合约从 msg.sender 转移 _value 数量的代币  
        ERC20Permit.permit(user, address(this), _value, deadline, v, r, s);  

        BaseERC20 ERC20 = BaseERC20(token);

        ERC20.transferFrom(user, address(this), _value);
        
        TokenBalances[token][user] += _value;
   }


}