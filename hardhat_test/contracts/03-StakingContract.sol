// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Interfaces/RewardTokenInterface.sol";
<<<<<<< HEAD
=======

>>>>>>> a677a62bc034960a1b779a32089563fc6fb84cd2
import "./04-SafeMath.sol";

contract TokenStaking is Ownable, Pausable, ReentrancyGuard, IERC721Receiver {
    IERC721 immutable stakingNFT;
    RewardTokenInterface immutable stakingRewardToken;
    uint immutable oneDayInSeconds = 1; //86400;
    using SafeMath for uint256;
    // Map user address to a mapping of the user's tokenid => index in arrray stored in Stake struct
    mapping(address => mapping(uint => uint)) private stakedIndicies;

    struct Stake {
        uint256[] tokenids;
        uint256 collectedTime;
        uint256 unclaimedRewards;
    }

    // map staker address to stake details
    mapping(address => Stake) public stakes;

    // mapping of tokenid => timestamp
    // each token is accounted for and a timestamp is provided for each token when staked
    // When unstaking get the starting time stamp using the token id being unstaked and get the difference.
    // map staker total staking time
    mapping(uint => uint) public tokenStakingTime;

    // Events
    event TokenReceived(uint256 _token, address _user);
    event TokenWithdrawn(uint256 _token, address _user);
    event TokenStaked(uint256 _token, address _user, uint256 timestamp);
    event TokenUnstaked(uint256 _tokenid, address _user, uint256 timestamp);

    constructor(IERC721 _parentNFT, RewardTokenInterface _rewardsToken) {
        stakingNFT = IERC721(_parentNFT);
        stakingRewardToken = _rewardsToken;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {
        require(tokenId >= 0, "Must provide a valid token");
        require(
            from == msg.sender || operator == stakingNFT.ownerOf(tokenId),
            "Operator is not the caller"
        );

        if (stakes[from].tokenids.length < 1) {
            Stake memory userStake = Stake({
                tokenids: new uint[](0),
                collectedTime: 0,
                unclaimedRewards: 0
            });
            stakes[from] = userStake;
            stakes[from].tokenids.push(tokenId);
            tokenStakingTime[tokenId] = block.timestamp;
        } else {
            stakes[from].tokenids.push(tokenId);
            tokenStakingTime[tokenId] = block.timestamp;
        }

        emit TokenReceived(tokenId, from);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function stakeToken(uint _tokenid) external nonReentrant {
        address owner = stakingNFT.ownerOf(_tokenid);
        require(
            msg.sender == owner ||
                stakingNFT.getApproved(_tokenid) == address(this),
            "Caller is not owner or approved to transfer token"
        );
        require(
            stakingNFT.getApproved(_tokenid) == address(this),
            "Token is not approved for staking"
        );
        require(
            checkTokenIsStaked(msg.sender, _tokenid) == false,
            "token not stakable"
        );
        stakingNFT.safeTransferFrom(owner, address(this), _tokenid);

        stakedIndicies[msg.sender][_tokenid] =
            stakes[msg.sender].tokenids.length -
            1;

        // map token id to index position in array
        emit TokenStaked(_tokenid, msg.sender, block.timestamp);
    }

    function unstakeToken(address _user, uint _tokenid) external nonReentrant {
        bool owner = checkOwner(_tokenid, _user);
        require(stakes[_user].tokenids.length > 0, "No token(s) staked");
        require(owner, "User does not own this token");
        // require(stakes[_user].unclaimedRewards < 0, "No rewards available to claim"); optional incase there is a minimum rwt withdraw
        bool staked = checkTokenIsStaked(_user, _tokenid);
        require(staked, "Token is not currently staked");
        stakingNFT.safeTransferFrom(address(this), _user, _tokenid); // Transfer token to user
        uint index = stakedIndicies[_user][_tokenid];
        // Calculate stake rewards
        uint amount = calculateStakeRewards(_user, _tokenid);
        removeElementAtIndex(index, _user); // Delete index of element staked from mapping
        tokenStakingTime[_tokenid] = 0;
        delete stakedIndicies[_user][_tokenid]; // Reset token index to default map value
        distributeTokens(_user, amount);
        emit TokenUnstaked(_tokenid, _user, block.timestamp);
    }

    function distributeTokens(address _user, uint _amount) private {
        stakingRewardToken.mintAndSend(_user, _amount);
    }

    function checkTokenIsStaked(
        address _user,
        uint _tokenid
    ) public view returns (bool) {
        if (stakes[_user].tokenids.length > 0) {
            uint index = stakedIndicies[_user][_tokenid];
            if (_tokenid == stakes[_user].tokenids[index]) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    function checkOwner(uint tokenid, address user) public returns (bool) {
        if (stakes[user].tokenids.length > 0) {
            uint index = stakedIndicies[user][tokenid];
            return true;
        } else {
            return false;
        }
    }

    // Remove token from user stake struct
    function removeElementAtIndex(uint index, address _user) internal {
        require(index < stakes[_user].tokenids.length, "Index out of bounds");
        uint length = stakes[_user].tokenids.length;
        stakes[_user].tokenids[index] = stakes[_user].tokenids[length - 1];
        stakes[_user].tokenids.pop();
    }

    // Each day a user has left their token staked, they get 1 token
    function calculateStakeRewards(
        address _user,
        uint _tokenid
    ) public returns (uint) {
        require(
            stakes[_user].tokenids.length > 0,
            "Must have a stake active to calculate rewards"
        );
        require(
            tokenStakingTime[_tokenid] >= oneDayInSeconds,
            "Must have staked for at least 24 hours"
        );
        require(
            msg.sender == stakingNFT.ownerOf(_tokenid),
            "User does not own this token"
        );
        uint timeDelta = block.timestamp.sub(tokenStakingTime[_tokenid]);
        uint rewards = timeDelta.div(oneDayInSeconds);
        return rewards;
    }

    // // Update the collected time value of the users stake struct
    // function updateCollectedStakedTime(address _user, uint _tokenid) internal {
    //     require(
    //         _user == stakingNFT.ownerOf(_tokenid),
    //         "User does not own this token"
    //     );
    //     uint delta = block.timestamp - tokenStakingTime[_tokenid];
    //     stakes[_user].collectedTime += delta;
    // }

    // Getter funcitons
    function getUserStake(
        address _userAddress
    ) public view returns (uint[] memory _tokenid, uint _totalStakeTime) {
        return (
            stakes[_userAddress].tokenids,
            stakes[_userAddress].collectedTime
        );
    }

    function getTokenStakeTime(uint _tokenid) public view returns (uint) {
        return tokenStakingTime[_tokenid];
    }

    function getUserTokenList(
        address user
    ) public view returns (uint[] memory) {
        return stakes[user].tokenids;
    }

    function getUserStakeTime(
        address _user
    ) public view returns (uint totalStakeTime) {
        return stakes[_user].collectedTime;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdraw() external onlyOwner nonReentrant returns (bool) {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
        return success;
    }
}
