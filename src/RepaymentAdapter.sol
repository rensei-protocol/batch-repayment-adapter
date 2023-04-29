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

    function approve(address currency, uint256 amount) public {
        if (!isContract(currency)) {
            revert InvalidCurrencyAddress();
        }

        if (IERC20(currency).balanceOf(msg.sender) < amount) {
            revert InSufficientBalance();
        }

        IERC20(currency).approve(address(this), amount);
    }

    constructor() {
        permitLoanContract[0x70b97A0da65C15dfb0FFA02aEE6FA36e507C2762] = 1;
        permitLoanContract[0xFa4D5258804D7723eb6A934c11b1bd423bC31623] = 2;
        permitLoanContract[0xE52Cec0E90115AbeB3304BaA36bc2655731f7934] = 3;
    }

    function batchApprove(address[] calldata currency, uint256[] calldata amount) public {
        if (currency.length != amount.length) {
            revert InvalidParameters();
        }
        for (uint256 i = 0; i < currency.length;) {
            approve(currency[i], amount[i]);
            unchecked {
                ++i;
            }
        }
    }

    function revoke(address currency) public {
        if (!isContract(currency)) {
            revert InvalidCurrencyAddress();
        }
        if (IERC20(currency).allowance(msg.sender, address(this)) == 0) {
            revert InvalidAllowance();
        }
        IERC20(currency).approve(address(this), 0);
    }

    function batchRevoke(address[] calldata currency) public {
        for (uint256 i = 0; i < currency.length;) {
            revoke(currency[i]);
            unchecked {
                ++i;
            }
        }
    }

    function batchRepayment(Repayment[] calldata repayment) public {
        for (uint256 i = 0; i < repayment.length;) {
            // todo use adapter contract or just keep it simple

            int256 flag = permitLoanContract[repayment[i].loanContract];
            bytes memory data;
            if (flag == 1) {
                data = abi.encodeWithSignature(
                    "repay(address,uint256,uint256)", repayment[i].collection, repayment[i].tokenId, repayment[i].amount
                );
            } else if (flag == 2) {
                data = abi.encodeWithSignature("repay(uint32)", repayment[i].loanId);
            } else if (flag == 3) {
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
