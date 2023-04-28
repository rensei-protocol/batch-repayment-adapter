# Batch Repayment Adapter

## Workflow:

1. Users approve BatchRepayment contract on target currencies (ERC20).

2. During batch repayment, users would first deposit funds into BatchRepayment contract (through ERC20's safeTransferFrom).

3. BatchRepayment then aggregates all repayment transactions, and invoke the loan contracts as the payer.

## User Interfaces:

```js
approve(address currency, uint256 amount)
```

```js
batchApprove(address[] calldata currency, uint256[] calldata amount)
```

```js
revoke(address currency)
```

```js
batchRevoke(address currency)
```

```js
batchRepayment(address[] calldata loanContract, address[] calldata currency, uint256[] amount)
```

## Admin Interfaces:

```js
allowLoanContractAsSpender(address[] loanContract)
```