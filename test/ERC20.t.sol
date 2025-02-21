// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/ERC20.sol";

contract ERC20ContractTest is Test {
    KiratCoin c;

    function setUp() public {
        c = new KiratCoin(address(this));
    }

    function testMint() public {
        uint value = 10;
        c.mint(address(this), value);

        assert(c.balanceOf(address(this)) == value);
    }

    function test_FailMint() public {
        uint value = 10;
        vm.startPrank(0x87cfdDb46689DC0343B496aEEd1265dECf5346d5);
        vm.expectRevert();

        c.mint(address(this), value);
    }
}
