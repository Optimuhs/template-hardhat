// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./04-SafeMath.sol";

contract RewardToken is ERC20, Ownable, Pausable {
    address private authorized; // Staking contract will be only minter allowed
    uint public TOTAL_SUPPLY = 100000;
    uint public CURRENT_SUPPLY = 0;
    using SafeMath for uint256;
    modifier onlyAuthorized() {
        require(msg.sender == authorized, "Unauthorized");
        _;
    }

    constructor() ERC20("rewardtoken", "RWT") {
        // Minting can be done in 2 ways
        // Mint all tokens to this contract or mint as rewards are generated
        // _mint(msg.sender, 100000 * 10 ** decimals());
    }

    function setAuthorized(address stakingContract) external onlyOwner {
        authorized = stakingContract;
    }

    function burn(uint256 amount) external whenNotPaused {
        require(amount > 0, "Amount must be greater than zero");
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external whenNotPaused {
        require(amount > 0, "Amount must be greater than zero");
        _approve(account, msg.sender, allowance(account, msg.sender) - amount);
        _burn(account, amount);
    }

    function mintFromMinter(
        address account,
        uint256 amount
    ) external whenNotPaused onlyAuthorized {
        require(amount > 0, "Amount must be greater than zero");
        _mint(account, amount);
    }

    function mintAndSend(
        address account,
        uint256 amount
    ) external whenNotPaused onlyAuthorized {
        require(amount > 0, "Amount must be greater than zero");
        // require(amount + CURRENT_SUPPLY <= TOTAL_SUPPLY, "Minting over supply");
        if (amount + CURRENT_SUPPLY > TOTAL_SUPPLY) {
            uint remainder = TOTAL_SUPPLY.sub(CURRENT_SUPPLY);
            _mint(account, remainder);
        } else {
            _mint(account, amount);
            // transfer(account, amount);
        }
    }

    function getAuthorized() public view returns (address) {
        return authorized;
    }
}
