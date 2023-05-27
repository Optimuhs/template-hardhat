// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract OptimuhsSingle is
    ERC721,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    Counters.Counter private s_tokenIdCounter;
    string public s_baseExtension = ".json";
    string private s_baseTokenURI;

    mapping(address => uint32) public s_mintList;
    mapping(address => uint[]) public tokenMapping;

    struct TokenMetadata {
        string name;
        string description;
        string image;
    }

    mapping(uint256 => TokenMetadata) private _tokenMetadata;

    struct SalesConfig {
        uint256 mintPrice;
        uint256 amountPerWallet;
        uint256 totalSupply;
    }
    SalesConfig public s_salesConfig;
    

    event SuccessfulMint(address user, uint256 amount);
    event RecievedPayment(address user, uint256 amount);
    event tokenMappingUpdated(address owner, uint256 tokenId);
    event tokenTransferred(address from, address to);
    constructor(
        uint256 mintPrice_,
        uint256 amountPerWallet_,
        uint256 totalSupply_
    ) ERC721("OptimuhsToken", "OPT") {
        //add totalSupply, mintPrice, amountPerWallet to constructor and replace with variables for different uses
        s_salesConfig.mintPrice = mintPrice_;
        s_salesConfig.amountPerWallet = amountPerWallet_;
        s_salesConfig.totalSupply = totalSupply_;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getCurrentMintCount() public view returns(uint) {
        return s_tokenIdCounter.current();
    }
    
    function getTokensOwned(address owner) public view returns(uint[] memory){
        return tokenMapping[owner];
    }

    function getTokenMetadata(uint tokenId) public view returns(TokenMetadata memory) {
        return _tokenMetadata[tokenId];
    }
    
    function safeMint(address to, TokenMetadata memory metadata) private {
        uint256 tokenId = s_tokenIdCounter.current();
        s_tokenIdCounter.increment();
        _safeMint(to, tokenId);
        updateTokenMetadataInternal(tokenId, metadata);
        tokenMapping[msg.sender].push(tokenId);
        emit SuccessfulMint(to, tokenId);
    }

    function mintNFT(TokenMetadata memory metadata) public payable {
        require(
            s_mintList[msg.sender] + 1 <= s_salesConfig.amountPerWallet,
            "Max mint limit per wallet reached"
        );
        require(msg.value >= s_salesConfig.mintPrice, "Not enough ETH");
        safeMint(msg.sender, metadata);
        s_mintList[msg.sender] += 1;
        refundIfOver(s_salesConfig.mintPrice);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function withdraw() external onlyOwner nonReentrant returns (bool) {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
        return success;
    }

    receive() external payable {
        emit RecievedPayment(msg.sender, msg.value);
    }

    function currentBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return s_baseTokenURI;
    }

    function getBase() external view returns (string memory){
        return s_baseTokenURI;
    }
    function updateBase(string memory newUri) external onlyOwner{
        s_baseTokenURI = newUri;
    }

    function getTokenIndex(uint tokenId) internal view returns(uint idx){
        // Find token index
        uint[] memory tokens =  tokenMapping[msg.sender];
        for (uint256 i = 0; i < tokens.length - 1; i++) {
            if(tokenId == tokens[i]){
                uint index = i;
                return index;
            }
        }
        
    }

    // Update the token mapping for transfers 
    function updateTokenMapping(uint tokenId, address to) internal {
        uint[] storage tokens = tokenMapping[msg.sender];
        uint index = getTokenIndex(tokenId);
        if(tokens.length == 1 && tokens.length > 0){
            uint token = tokens[0];
            tokens.pop();
            tokenMapping[to].push(token);
        }else{
            // Remove the token
            uint token = removeToken(index, msg.sender);
            // Update token to be on receiver 
            tokenMapping[to].push(token);
        }
    }   
    
    // Remove token from array in TokenMapping
    function removeToken(uint index, address from) internal returns(uint tokenRemoved){
        uint[] storage tokens = tokenMapping[from];
        require(index < tokens.length, "Invalid index");
        uint token = tokens[index];
        // Shift elements to the left starting from the index
        for (uint256 i = index; i < tokens.length - 1; i++) {
            tokens[i] = tokens[i + 1];
        }
        // Decrease the array length by 1
        tokens.pop();
        return token;
    }

    // Override the transferFrom function
    function transferFrom(address from, address to, uint256 tokenId) public override {
        // Additional checks or logic before the transfer
        require(ownerOf(tokenId) == from, "Owner is not transfering this token");
        // Call the base implementation of transferFrom
        super.transferFrom(from, to, tokenId);
        updateTokenMapping(tokenId, to);
        emit tokenTransferred(from, to);
    }

    function updateTokenMetadataInternal(uint256 tokenId, TokenMetadata memory metadata) internal  {
        require(_exists(tokenId), "ERC721Metadata: Metadata query for nonexistent token");
        _setTokenMetadata(tokenId, metadata);
    }

    function updateTokenMetadataExternal(uint256 tokenId, TokenMetadata memory metadata) external onlyOwner {
        require(msg.sender == owner() || msg.sender == address(this), "Ownable: caller is not the owner");
        require(_exists(tokenId), "ERC721Metadata: Metadata query for nonexistent token");
        _setTokenMetadata(tokenId, metadata);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        TokenMetadata memory metadata = _tokenMetadata[tokenId];
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, metadata.image)) : "";
    }

    function _setTokenMetadata(uint256 tokenId, TokenMetadata memory metadata) internal {
        _tokenMetadata[tokenId] = metadata;
    }
}
