// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface RewardTokenInterface is IERC20 {
    function mint(address account, uint256 amount, address minter) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function mintFromMinter(address account, uint256 amount) external;

    function mintAndSend(address account, uint256 amount) external;
}
