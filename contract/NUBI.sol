pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract NFT {
    function walletOfOwner(address) public pure returns (uint256[] memory) {}
}

contract NUBICoin is ERC20 {
    address public admin; 
    address public mintableNFT;
    uint256 public mintUnitBySec;
    uint public initTime;
    mapping(uint => uint) public lastTimeMinted;
    mapping(uint => address) public lastHolderMinted;
    NFT nftContract;

    constructor() ERC20('NUBICoin', 'NUBI') {
        _mint(msg.sender, 100000000000 * 10 ** 18);
        mintableNFT = 0xB2A2812402ad53Bd79d8ADC0b6DE282bDBc25336;
        mintUnitBySec = 5000000000000000;
        admin = msg.sender;
        initTime = block.timestamp;
    }
    function setMinableNFT(address _t) external {
        require(msg.sender == admin, 'only admin');
        mintableNFT = _t;
    }
    function setMintUnitBySec(uint amount) external {
        require(msg.sender == admin, 'only admin');
        mintUnitBySec = amount;
    }
    function mint(address to, uint amount) external {
        require(msg.sender == admin, 'only admin');
        _mint(to, amount);
    }
    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }
    function mintWithNFT() external{
        nftContract = NFT(mintableNFT);
        uint[] memory tokens = nftContract.walletOfOwner(msg.sender);
        uint newCoin = 0;
        uint tokenId;
        uint newTime = block.timestamp;
        for (uint i = 0; i < tokens.length; i++) {
            tokenId = tokens[i];
            if(lastHolderMinted[tokenId] != msg.sender) {
                // reset holder
                lastHolderMinted[tokenId] = msg.sender;
            }else{
                // mint for the holder
                newCoin += (newTime - lastTimeMinted[tokenId])*mintUnitBySec;
            }
            lastTimeMinted[tokenId] = newTime;
        }
        _mint(msg.sender, newCoin);
    }
}