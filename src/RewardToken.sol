// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "node_modules/openzeppelin-solidity/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    constructor() ERC20("Reward Token", "RWT") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10**decimals()); 
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}