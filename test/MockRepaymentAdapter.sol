// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/IRepaymentAdapter.sol";
import {IWETH9} from "../src/IWETH9.sol";

contract MockRepaymentAdapter is IRepaymentAdapter, Ownable {
    event Received(address, uint256);

    IWETH9 public WETH9;

    constructor(address weth) {
        WETH9 = IWETH9(weth);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function withdrawWETH(uint256 amount) public onlyOwner returns (uint256) {
        WETH9.withdraw(amount);
        return address(this).balance;
    }
}
