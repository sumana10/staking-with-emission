// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "node_modules/openzeppelin-solidity/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    address public stakingContract;

    constructor(address initialOwner) ERC20("Reward Token", "RWT") Ownable(initialOwner) {
        stakingContract = address(0);
    }

    modifier onlyStakingContract() {
        require(msg.sender == stakingContract, "Not authorized");
        _;
    }

    function setStakingContract(address _stakingContract) public onlyOwner {
        require(_stakingContract != address(0), "Invalid address");
        stakingContract = _stakingContract;
    }

    function mint(address to, uint256 amount) external onlyStakingContract {
        _mint(to, amount);
    }
}