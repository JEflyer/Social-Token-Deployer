//SPDX-License_Identifier: MIT
pragma solidity ^0.8.7;

import "./taxToken.sol";
import "./paidToken.sol";

contract deployer {
    
    address payable owner;
    mapping (uint => address) public tokenAddresses;
    uint deployementPrice;
    uint taxDiv;
    uint currentTokenId;
    
    constructor (
        uint _deployPrice,
        uint _taxDiv
        ) {
            owner = payable(msg.sender);
            deployementPrice = _deployPrice;
            taxDiv = _taxDiv;
            currentTokenId = 0;
        }
    
    modifier onlyOwner {
        require(msg.sender == owner, "you can not call this function");
        _;
    }
    
    function changeDeployPrice ( uint _newPrice) public onlyOwner {
        deployementPrice = _newPrice;
    }
    
    function changeTaxDiv (uint _newDiv) public onlyOwner {
        taxDiv = _newDiv;
    }
    
    event NewNoTaxToken (uint tokenId, address tokenAddress, address tokenOwner, string name, string symbol);
    event NewTaxToken (uint tokenId, address tokenAddress, address tokenOwner, string name, string symbol);
    
    function deployPaidToken (
        string memory _name,
        string memory _symbol
        ) public payable returns(uint) {
            require(msg.value >= deployementPrice, "You need to send more moneys");
            
            owner.transfer(msg.value);
            
            currentTokenId++;
            
            tokenAddresses[currentTokenId] = address(new PaidToken(
                _name,
                _symbol,
                1000000,
                msg.sender
                ));
                
            emit NewNoTaxToken ( 
                currentTokenId,
                tokenAddresses[currentTokenId],
                msg.sender,
                _name,
                _symbol
                );
                
            return currentTokenId;
        }
        
    function deployTaxToken (
        string memory _name,
        string memory _symbol
        ) public returns(uint) {
            
            currentTokenId++;
            
            tokenAddresses[currentTokenId] = address(new TaxToken(
                _name,
                _symbol,
                1000000,
                msg.sender,
                owner,
                taxDiv
                ));
                
            emit NewTaxToken ( 
                currentTokenId,
                tokenAddresses[currentTokenId],
                msg.sender,
                _name,
                _symbol
                );
                
            return currentTokenId;
        }
}

----------------------------------------------------------------------------------------------

//SPDX-License_Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract PaidToken is ERC20PresetFixedSupply {
    
    constructor (
        string memory _name,
        string memory _symbol,
        uint _tokenLimit,
        address _tokenOwner
        ) ERC20PresetFixedSupply (
            _name,
            _symbol,
            _tokenLimit * 10 ** 18,
            _tokenOwner
            ){}
    
}


----------------------------------------------------------------------------------------------

//SPDX-License_Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract TaxToken is ERC20PresetFixedSupply {
    
    address taxTo;
    uint taxDiv;
    mapping (address => uint) public balances;
    
    constructor (
        string memory _name,
        string memory _symbol,
        uint _tokenLimit,
        address _tokenOwner,
        address _taxTo,
        uint _taxDiv
        ) ERC20PresetFixedSupply (
            _name,
            _symbol,
            _tokenLimit * 10 ** 18,
            _tokenOwner
            ){
                balances[_tokenOwner] = _tokenLimit;
                taxTo = _taxTo;
                taxDiv = _taxDiv;
                
            }
            
    function transfer (address _to, uint _amount) public override returns (bool) {
        
        require(balances[msg.sender] >= _amount, "You're too poor");
        
        uint tax = _amount / taxDiv;
        
        balances[msg.sender] -= _amount;
        balances[taxTo] += tax;
        balances[_to] += _amount - tax;
        
        return true;
        
    }
    
}
