// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IRepaymentAdapter.sol";

contract RepaymentAdapter is IRepaymentAdapter {
    using SafeERC20 for IERC20;

    mapping(address => bool) public permitLoanContract;

    function approve(address currency, uint256 amount) public {
        if (!isContract(currency)) {
            revert InvalidCurrencyAddress();
        }

        if (IERC20(currency).balanceOf(msg.sender) < amount) {
            revert InSufficientBalance();
        }

        IERC20(currency).approve(address(this), amount);
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

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
