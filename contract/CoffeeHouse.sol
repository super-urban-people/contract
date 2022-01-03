// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.4.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.4.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.4.0/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts@4.4.0/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @custom:security-contact superurbanpeople@gmail.com
contract CoffeeHouse is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
    address _mintTokenAddress = 0x4800CD8197c015fB6975D6b603f62bB429729Eba;
    IERC20 private mintToken;
    uint256[] public prices = [50 ether, 55 ether]; // Hot, Ice
    string[] public messages;
    uint256 public wallSize = 10;
    uint256 public textLimit = 140;
    string public baseExtension = ".json";
    string public name = "CoffeeHouse";
    string public symbol = "SUPCH";
    constructor() ERC1155("ipfs://QmRa3NWZJdXS4Q4f5unjGAwUF34dYydwUSQtSqf95C3yBG/{id}.json") {
        mintToken = IERC20(_mintTokenAddress);
        _resetWall();
    }
    function _resetWall() internal{
        messages = new string[](wallSize);
        for( uint256 i = 0; i<wallSize ; i++){
            messages[i] = "drink a coffee";
        }
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    function setMintToken(address _address) public onlyOwner{
        _mintTokenAddress = _address;
        mintToken = IERC20(_mintTokenAddress);
    }
    function setWallSize(uint256 newSize) public onlyOwner{
        wallSize = newSize;
        _resetWall();
    }
    function setTextLimit(uint256 newLimit) public onlyOwner{
        textLimit = newLimit;
    }

    function setPrices(uint256[] memory _prices) public onlyOwner {
        prices = _prices;
    }

    function mint(uint256 id, uint256 amount)
        public
    {
        require(id > 0, "Token doesn't exist");
        require(id <= prices.length, "Token doesn't exist");
        uint256 index = id -1;
        uint256 totalPrice = amount * prices[index];

        require(mintToken.allowance(msg.sender, address(this)) >= totalPrice, "Not enough allowance");
        mintToken.transferFrom(msg.sender, address(this), totalPrice);

        _mint(msg.sender, id, amount, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, "");
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
    function drink(uint256 id, uint256 amount, string memory message)
        public
    {
        require(id > 0, "Token doesn't exist");
        require(id <= prices.length, "Token doesn't exist");
        require(balanceOf(msg.sender, id) >= amount, "Not enough token");

        uint256 rev;
        for (uint256 i = 0; i<wallSize ; i++){ 
            // 9,8,7,6,...,1,0
            rev = 9-i;
            if ( rev >= amount ){
                messages[rev] = messages[rev-amount];
            }else{
                messages[rev] = message;                    
            }
        }
        burn(msg.sender, id, amount);
    }
}
