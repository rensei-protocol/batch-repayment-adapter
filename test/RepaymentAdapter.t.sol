// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {MockRepaymentAdapter} from "./MockRepaymentAdapter.sol";
import {WETH9} from "./WETH9.sol";

contract RepaymentAdapterTest is Test {
    MockRepaymentAdapter public repaymentAdapter;
    WETH9 public wETH9;

    function setUp() public {
        wETH9 = new WETH9();
        repaymentAdapter = new MockRepaymentAdapter(address(wETH9));
    }

    function test_withdraw_weth() public {
        uint256 balance = repaymentAdapter.withdrawWETH(0);
        console.log(balance);

        wETH9.deposit{value: 1000}();
        wETH9.transfer(address(repaymentAdapter), 1000);

        uint256 balanceAfter = repaymentAdapter.withdrawWETH(1000);
        console.log(balanceAfter);
    }
}
