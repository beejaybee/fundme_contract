// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";
import { FundFundMe, WithdrawFundMe } from "../../script/Interactions.s.sol";


contract Interactions is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
   
    // address user2 = address(0x2);
    // address owner;

    uint256 constant MINIMUM_USD = 5e18;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 constant GasPrice = 1;
    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_VALUE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundme(address(fundMe));

        WithdrawFundMe withdrawFundMe =  new WithdrawFundMe();
        withdrawFundMe.withdrawFundme(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}