// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/StakingWithEmissions.sol";
import "src/ERC20.sol";

contract StakingWithEmissionsTest is Test {
    StakingWithEmissions stakingContract;
    KiratCoin kiratToken;

    function setUp() public {
        kiratToken = new KiratCoin(address(this)); // KiratCoin deploy with random address
        stakingContract = new StakingWithEmissions(
            IKiratToken(address(kiratToken)) // StakingContract deploy with
        );
        kiratToken.updateContract(address(stakingContract));
    }

    function testStake() public {
        uint value = 10 ether;
        stakingContract.stake{value: value}(value);

        assert(stakingContract.totalStake() == value);
    }

    function test_FailUnstake() public {
        uint value = 10 ether;
        stakingContract.stake{value: value}(value);
        vm.expectRevert("Not enough staked");
        stakingContract.unstake(value + 1 ether);
    }

    function testGetRewards() public {
        uint value = 1 ether;
        stakingContract.stake{value: value}(value);
        vm.warp(block.timestamp + 1);
        uint rewards = stakingContract.getRewards();

        assert(rewards == 1 ether);
    }

    function testComplexGetRewards() public {
        uint value = 1 ether;
        stakingContract.stake{value: value}(value);
        vm.warp(block.timestamp + 1);
        console.log(block.timestamp);
        stakingContract.stake{value: value}(value);
        vm.warp(block.timestamp + 1);
        uint rewards = stakingContract.getRewards();

        assert(rewards == 3 ether);
    }

    function testRedeemRewards() public {
        uint value = 1 ether;
        stakingContract.stake{value: value}(value);
        vm.warp(block.timestamp + 1);
        stakingContract.claimEmissions();
        console.log("balance of");
        console.log(kiratToken.balanceOf(address(this)));

        assert(kiratToken.balanceOf(address(this)) == 1 ether);
    }
}
//0x01B46fCf9Be57f788e40c012B099D2aA6981cd7d