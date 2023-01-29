// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract OptimuhsToken is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint public MAX_MINT = 1000;
    string public baseExtension = ".json";
    uint private currentMinted = 0;
    string private _baseTokenURI;

    mapping(address => uint32) public mintList;

    struct SalesConfig{
        uint256 mintPrice;
        uint256 amountPerWallet;
        uint256 freeSupply;
        uint256 totalSupply;
    }
    SalesConfig public salesConfig;

    event SuccessfulMint(address user, uint amount, uint value);
    event RecievedPayment(address user, uint amount);

    constructor(
        uint256 mintPrice_,
        uint256 amountPerWallet_,
        uint256 freeSupply_,
        uint256 totalSupply_
    ) ERC721("OptimuhsToken", "OPT") {
        salesConfig.mintPrice = mintPrice_;
        salesConfig.amountPerWallet = amountPerWallet_;
        salesConfig.freeSupply = freeSupply_;
        salesConfig.totalSupply = totalSupply_;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) private {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function mintNFT(uint256 amount) public payable{
        require(mintList[msg.sender] < MAX_MINT, "Max mint limit per wallet reached");
        require(msg.value > amount * salesConfig.mintPrice, "Not enough ETH");
        safeMint(msg.sender, _baseTokenURI);
        mintList[msg.sender] += uint32(amount);
        _tokenIdCounter.increment();
        
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH");
        if(msg.value > price){
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token:");
        return super.tokenURI(tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory){
        return _baseTokenURI;
        
    }

    function withdraw() external onlyOwner nonReentrant returns(bool){
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
        return success;
    }

    receive() external payable {
        emit RecievedPayment(msg.sender, msg.value);
    }
}


