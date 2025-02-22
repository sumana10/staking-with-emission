
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;
import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract HybridStaking {
    uint256 public totalStaked;
    uint256 public constant REWARD_PER_SEC_PER_ETH = 1; 
    uint256 public constant BASIS_POINTS = 10000;
    
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    
    enum StakingType { FLEXIBLE, LOCKED }

    struct StakeInfo {
        uint256 amount;
        uint256 timestamp;
        uint256 lockDuration;
        StakingType stakeType;
        uint256 rewardDebt;
    }
    
    mapping(address => StakeInfo) public stakes;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 amount, StakingType stakeType, uint256 lockDuration) external {
        require(amount > 0, "Amount must be greater than 0");
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        totalStaked += amount;
        
        stakes[msg.sender] = StakeInfo({
            amount: amount,
            timestamp: block.timestamp,
            lockDuration: (stakeType == StakingType.LOCKED) ? lockDuration : 0,
            stakeType: stakeType,
            rewardDebt: 0
        });
    }

    function unstake() external {
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No staked balance");

        if (userStake.stakeType == StakingType.LOCKED) {
            require(block.timestamp >= userStake.timestamp + userStake.lockDuration, "Lock period not over");
        }

        uint256 reward = calculateReward(msg.sender);
        totalStaked -= userStake.amount;
        stakingToken.transfer(msg.sender, userStake.amount);

        if (reward > 0) {
            rewardToken.transfer(msg.sender, reward);
        }

        delete stakes[msg.sender];
    }

 //The `calculateReward` function in the HybridStaking contract is responsible for calculating the reward 
 //that a user is eligible to receive based on their staked amount, staking duration, and staking type (Flexible or Locked).
    function calculateReward(address user) public view returns (uint256) {
        StakeInfo storage userStake = stakes[user];
        if (userStake.amount == 0) return 0;

        uint256 duration = block.timestamp - userStake.timestamp;
        if (userStake.stakeType == StakingType.FLEXIBLE) {
            return (userStake.amount * duration * REWARD_PER_SEC_PER_ETH);
        } else {
            uint256 apr = (userStake.lockDuration >= 90 days) ? 1000 : 500; // 10% for 90+ days, 5% for 30 days
            return (userStake.amount * apr * duration) / (365 days * BASIS_POINTS);
        }
    }

    function claimRewards() external {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to claim");

        stakes[msg.sender].timestamp = block.timestamp;
        rewardToken.transfer(msg.sender, reward);
    }
}






















//0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B