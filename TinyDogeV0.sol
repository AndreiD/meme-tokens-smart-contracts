// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TinyDogeV0 is ERC20 {
  
    uint256 public counter = 0;
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
       _mint(_msgSender(), 1000000000 * 10 ** 18);        
    }

    function transfer(address to, uint256 value) public override returns (bool) {      
       counter++;       
       _transfer(_msgSender(), to, value); // Transfer amount after tax        
       return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {      
        counter++;
       _spendAllowance(from, _msgSender(), value);
       _transfer(from, to, value);                     
        return true;
    }
}
