// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface OptimuhsSingleInterface {
     struct TokenMetadata {
        string name;
        string description;
        string image;
    }
    // Allows owner to pause contract functions
    function pause() external ;

    // Allows owner to unpause contract functions
    function unpause() external ;

    // Does the actual minting
    function safeMint(address to, TokenMetadata memory metadata) external;

    // Mint a token 
    function mintNFT(TokenMetadata memory metadata) external payable;

    // If a user sends too much they are refunded
    function refundIfOver(uint256 price) external;

    // Allow owner to withdraw any funds received
    function withdraw() external returns (bool);

    // Return token metadata for a specific token
    function getTokenMetadata(uint tokenId) external view returns(TokenMetadata memory);
    
    // Receive fallback
    receive() external payable ;

    // Overridden  transferFrom function
    function transferFrom(address from, address to, uint256 tokenId) external ;

    // Allow for external metadata updates but owner
    function updateTokenMetadataExternal(uint256 tokenId, TokenMetadata memory metadata) external  ;

    // Return the token URI
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // Return the token uri Base
    function getBase() external view returns (string memory);


    // Returns the array of tokens owned
    function getTokensOwned(address owner) external view returns(uint[] memory);

    // Return current token balance for the caller
    function currentBalance() external view returns (uint256) ;

    // Get the current token count
    function getCurrentMintCount() external view returns(uint);
}
