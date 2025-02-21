// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "forge-std/Test.sol";

contract KiratCoin is ERC20 {
    address stakingContract;

    constructor(address _stakingContract) ERC20("KiratCoin", "KIRA") {
        stakingContract = _stakingContract;
    }

    modifier onlyContract() {
        require(msg.sender == stakingContract);
        _;
    }

    function mint(address to, uint256 amount) public onlyContract {
        _mint(to, amount);
    }

    function updateContract(address newContract) public onlyContract {
        stakingContract = newContract;
    }
}
//0x46Acf5C509fB2464b538fc8551F540660E92Cd07