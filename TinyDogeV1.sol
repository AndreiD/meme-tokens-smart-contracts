
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//acc1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//acc2: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
contract TinyDogeV1 is ERC20 {
      
    uint256 public taxPercentage = 1000; //default 10%

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
       _mint(_msgSender(), 1000000000 * 10 ** 18);        
    }

    function transfer(address to, uint256 value) public override returns (bool) {   

        uint256 taxAmount = value * taxPercentage / 10000; // Calculate tax amount
        uint256 amountAfterTax = value - taxAmount;

        _transfer(_msgSender(), to, amountAfterTax); // Transfer to the user value-tax
        if (taxAmount > 0) {
            _transfer(_msgSender(), address(this), taxAmount); //transfer to contract the tax
        }           
       return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {           
       _spendAllowance(from, _msgSender(), value);

       uint256 taxAmount = value * taxPercentage / 10000; // Calculate tax amount
        uint256 amountAfterTax = value - taxAmount;

        _transfer(from, to, amountAfterTax); // Transfer amount after tax
        if (taxAmount > 0) {
           _transfer(_msgSender(), address(this), taxAmount); //transfer to contract the tax
        }
       
        return true;
    }
    
    function setTaxPercentage(uint256 _taxPercentage) external {
        require(_taxPercentage <= 1000, "must be less then 10");
        taxPercentage = _taxPercentage;
    }   
}
