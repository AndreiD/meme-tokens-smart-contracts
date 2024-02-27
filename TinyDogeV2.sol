
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TinyDogeV2 is ERC20, Ownable, ERC20Permit {
      
    uint256 public taxPercentage = 1000; //default 10%
    mapping(address => bool) public taxExempt; // Mapping to store tax-exempt wallets

    constructor(string memory _name, string memory _symbol, address _initialOwner) 
    ERC20(_name, _symbol) 
    Ownable(_initialOwner)
    ERC20Permit("TinyDogeV2")
    {
       _mint(owner(), 1000000000 * 10 ** 18);       
       setTaxExemptAddress(owner(), true); 
       setTaxExemptAddress(address(this), true);
    }

    function transfer(address to, uint256 value) public override returns (bool) {   
        
        if (taxExempt[_msgSender()] || taxExempt[to]) {
            _transfer(_msgSender(), to, value); // Transfer without tax deduction
            return true;
        }

        uint256 taxAmount = value * taxPercentage / 10000; // Calculate tax amount
        uint256 amountAfterTax = value - taxAmount;

        _transfer(_msgSender(), to, amountAfterTax); // Transfer to the user value-tax
        if (taxAmount > 0) {
            _transfer(_msgSender(), address(this), taxAmount); //transfer to contract the tax
        }           
       return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public override returns (bool) { 

        if (taxExempt[_msgSender()] || taxExempt[to]) {
            _transfer(from, to, value); // Transfer without tax deduction
            return true;
        }

       _spendAllowance(from, _msgSender(), value);

       uint256 taxAmount = value * taxPercentage / 10000; // Calculate tax amount
        uint256 amountAfterTax = value - taxAmount;

        _transfer(from, to, amountAfterTax); // Transfer amount after tax
        if (taxAmount > 0) {
           _transfer(_msgSender(), address(this), taxAmount); //transfer to contract the tax
        }
       
        return true;
    }
    
    function setTaxPercentage(uint256 _taxPercentage) external onlyOwner {
        require(_taxPercentage <= 1000, "must be less then 10");
        taxPercentage = _taxPercentage;
    }  

    /**
     * @dev Adds/Removes an address to the list of tax-exempt wallets.
     * Can only be called by the owner.
     */
    function setTaxExemptAddress(address _address, bool _isTaxExempt) public onlyOwner {
        taxExempt[_address] = _isTaxExempt;
    } 

     /**
     * @dev Allows the owner to withdraw accumulated taxes.
     */
    function withdrawTaxes(uint256 amount) public onlyOwner {       
        _transfer(address(this), _msgSender(), amount);
    }
}
