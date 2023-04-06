// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Interfaces/RewardTokenInterface.sol";
import "./04-SafeMath.sol";

contract TokenStakingInterface is
    Ownable,
    Pausable,
    ReentrancyGuard,
    IERC721Receiver
{
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external returns (bytes4);

    function stakeToken(uint _tokenid) external nonReentrant;

    function unstakeToken(address _user, uint _tokenid) external nonReentrant;

    function checkTokenIsStaked(
        address _user,
        uint _tokenid
    ) external view returns (bool);

    function checkOwner(uint tokenid, address user) external returns (bool);

    // Each day a user has left their token staked, they get 1 token
    function calculateStakeRewards(
        address _user,
        uint _tokenid
    ) external returns (uint);

    // Getter funcitons
    function getUserStake(
        address _userAddress
    ) external view returns (uint[] memory _tokenid, uint _totalStakeTime);

    function getTokenStakeTime(uint _tokenid) external view returns (uint);

    function getUserTokenList(
        address user
    ) external view returns (uint[] memory);

    function getUserStakeTime(
        address _user
    ) external view returns (uint totalStakeTime);

    function pause() external onlyOwner;

    function unpause() external onlyOwner;

    function withdraw() external onlyOwner nonReentrant returns (bool);
}
