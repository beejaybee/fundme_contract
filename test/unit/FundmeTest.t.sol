// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundMe;

    address USER = makeAddr("user");
   
    // address user2 = address(0x2);
    // address owner;

    uint256 constant MINIMUM_USD = 5e18;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 constant GasPrice = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // owner = address(this);
        vm.deal(USER, STARTING_VALUE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisSetCorrectly() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionIsCorrect() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundRevertsIfBelowMinimum() public {
        vm.expectRevert();
        fundMe.fund(); // Sending insufficient funds
        
    }

    function testFundUpdatesAmountFunded() public {
        vm.prank(USER); //The next Tx will be sent by user
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawalWithASingleAccount() public funded {
        //Arrange 

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert Methodoologies
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // Arrange
            // vm.prank
            // vm.deal
            hoax(address(i), SEND_VALUE);
            // fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // Arrange
            // vm.prank
            // vm.deal
            hoax(address(i), SEND_VALUE);
            // fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    } 
}