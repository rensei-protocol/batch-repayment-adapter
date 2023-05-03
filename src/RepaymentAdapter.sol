// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IRepaymentAdapter.sol";

contract RepaymentAdapter is IRepaymentAdapter {
    using SafeERC20 for IERC20;

    // 1. BendDAO
    // 2. X2Y2
    // 3. NFTFi
    mapping(address => int256) public permitLoanContract;

    constructor() {
        permitLoanContract[0x70b97A0da65C15dfb0FFA02aEE6FA36e507C2762] = 1;
        permitLoanContract[0xFa4D5258804D7723eb6A934c11b1bd423bC31623] = 2;
        permitLoanContract[0xE52Cec0E90115AbeB3304BaA36bc2655731f7934] = 3;
    }

    function batchRepayment(Repayment[] calldata repayment) public {
        for (uint256 i = 0; i < repayment.length;) {
            // todo use adapter contract or just keep it simple
            int256 flag = permitLoanContract[repayment[i].loanContract];
            bytes memory data;
            if (flag == 1) {
                require(isContract(repayment[i].collection), "Invalid collection address");
                require(repayment[i].tokenId > 0, "Invalid token id");
                require(repayment[i].amount > 0, "Invalid amount");
                data = abi.encodeWithSignature(
                    "repay(address,uint256,uint256)", repayment[i].collection, repayment[i].tokenId, repayment[i].amount
                );
            } else if (flag == 2) {
                require(repayment[i].loanId > 0, "Invalid loan id");
                data = abi.encodeWithSignature("repay(uint32)", repayment[i].loanId);
            } else if (flag == 3) {
                require(repayment[i].loanId > 0, "Invalid loan id");
                data = abi.encodeWithSignature("repay(uint32)", repayment[i].loanId);
            } else {
                revert InvalidLoanContractAddress();
            }
            IERC20(repayment[i].currency).safeTransferFrom(msg.sender, address(this), repayment[i].amount);
            (bool success, bytes memory ret) = repayment[i].loanContract.call(data);
            if (!success) {
                revert InvalidContractCall();
            }

            unchecked {
                ++i;
            }
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
