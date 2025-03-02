// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

interface IRewardToken {
    function mint(address to, uint256 amount) external;
}

contract HybridStaking {
    uint256 public totalStaked;
    uint256 public constant REWARD_PER_SEC_PER_ETH = 1; // Emissions Rate
    uint256 public constant BASIS_POINTS = 10000;
    
    IERC20 public stakingToken;
    IRewardToken public rewardToken;
    
    enum StakingType { FLEXIBLE, LOCKED }

    struct StakeInfo {
        uint256 amount;
        uint256 timestamp;
        uint256 lockDuration;
        StakingType stakeType;
        uint256 rewardDebt;
        uint256 lastUpdate;
    }
    
    mapping(address => StakeInfo) public stakes;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IRewardToken(_rewardToken);
    }

    function _updateRewards(address user) internal {
        StakeInfo storage userStake = stakes[user];

        if (userStake.amount == 0) return;
        
        uint256 timeDiff = block.timestamp - userStake.lastUpdate;
        if (timeDiff == 0) return;

        uint256 additionalReward = (userStake.stakeType == StakingType.FLEXIBLE)
            ? (userStake.amount * timeDiff * REWARD_PER_SEC_PER_ETH)
            : (userStake.amount * _getAPR(userStake.lockDuration) * timeDiff) / (365 days * BASIS_POINTS);

        userStake.rewardDebt += additionalReward;
        userStake.lastUpdate = block.timestamp;
    }

    function _getAPR(uint256 lockDuration) internal pure returns (uint256) {
        return (lockDuration >= 90 days) ? 1000 : 500; // 10% for 90+ days, 5% for 30 days
    }

    function stake(uint256 amount, StakingType stakeType, uint256 lockDuration) external {
        require(amount > 0, "Amount must be greater than 0");
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        _updateRewards(msg.sender);

        totalStaked += amount;
        
        stakes[msg.sender] = StakeInfo({
            amount: amount,
            timestamp: block.timestamp,
            lockDuration: (stakeType == StakingType.LOCKED) ? lockDuration : 0,
            stakeType: stakeType,
            rewardDebt: stakes[msg.sender].rewardDebt,
            lastUpdate: block.timestamp
        });
    }

    function unstake() external payable{
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No staked balance");

        _updateRewards(msg.sender);

        if (userStake.stakeType == StakingType.LOCKED) {
            require(block.timestamp >= userStake.timestamp + userStake.lockDuration, "Lock period not over");
        }

        uint256 reward = userStake.rewardDebt;
        totalStaked -= userStake.amount;

        stakingToken.transfer(msg.sender, userStake.amount);
        if (reward > 0) {
            rewardToken.mint(msg.sender, reward);
        }

        delete stakes[msg.sender];
    }

    function claimRewards() external {
        _updateRewards(msg.sender);
        uint256 reward = stakes[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");

        stakes[msg.sender].rewardDebt = 0;
        rewardToken.mint(msg.sender, reward);
    }

    function getRewards(address user) external view returns (uint256) {
        StakeInfo storage userStake = stakes[user];
        uint256 timeDiff = block.timestamp - userStake.lastUpdate;
        if (timeDiff == 0) {
            return userStake.rewardDebt;
        }

        uint256 additionalReward = (userStake.stakeType == StakingType.FLEXIBLE)
            ? (userStake.amount * timeDiff * REWARD_PER_SEC_PER_ETH)
            : (userStake.amount * _getAPR(userStake.lockDuration) * timeDiff) / (365 days * BASIS_POINTS);

        return userStake.rewardDebt + additionalReward;
    }
}
