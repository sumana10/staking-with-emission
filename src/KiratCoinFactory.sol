// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ERC20.sol";
import "./StakingWithEmissions.sol";

contract KiratCoinFactory {
    event ContractsCreated(address kiratCoin, address stakingContract);

    function deployContracts() public {
        KiratCoin kiratCoin = new KiratCoin(address(this)); 

        StakingWithEmissions stakingContract = new StakingWithEmissions(IKiratToken(address(kiratCoin)));

        kiratCoin.updateContract(address(stakingContract));

        emit ContractsCreated(address(kiratCoin), address(stakingContract));
    }
}