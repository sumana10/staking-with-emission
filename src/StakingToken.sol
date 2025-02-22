// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20 {
    constructor() ERC20("Stake Token", "STK") {
        _mint(msg.sender, 1_000_000 * 10**decimals()); 
    }
}