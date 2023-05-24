# Batch Repayment Adapter

## Workflow:

1. Users approve BatchRepayment contract on target currencies (ERC20).

2. During batch repayment, users would first deposit funds into BatchRepayment contract (through ERC20's safeTransferFrom).

3. BatchRepayment then aggregates all repayment transactions, and invoke the loan contracts as the payer.

4. Remaning funds returned by loan contracts would be returned to initiators.

## DataType

```js
struct Repayment{
    address loanContract;
    address collection;
    uint256 tokenId;
    uint256 amount;
    uint32 loanId;
}
```

## User Interfaces:

```js
batchRepayment(Repayment[] calldata repayment)
```

## Deployment

- Ethereum Mainnet: 0x162A5Be0Ce0425472d5bC496CDd0669135f36458

## Resource

### Benddao

```
  /**
   * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent loan owned
   * - E.g. User repays 100 USDC, burning loan and receives collateral asset
   * @param nftAsset The address of the underlying NFT used as collateral
   * @param nftTokenId The token ID of the underlying NFT used as collateral
   * @param amount The amount to repay
   * @return The final amount repaid, loan is burned or not
   **/
  function repay(
    address nftAsset,
    uint256 nftTokenId,
    uint256 amount
  ) external returns (uint256, bool);
  ```

### NFTFi

```
/**
    * @notice This function is called by a anyone to repay a loan. It can be called at any time after the loan has
    * begun and before loan expiry.. The caller will pay a pro-rata portion of their interest if the loan is paid off
    * early and the loan is pro-rated type, but the complete repayment amount if it is fixed type.
    * The the borrower (current owner of the obligation note) will get the collaterl NFT back.
    *
    * This function is purposefully not pausable in order to prevent an attack where the contract admin's pause the
    * contract and hold hostage the NFT's that are still within it.
    *
    * @param _loanId  A unique identifier for this particular loan, sourced from the Loan Coordinator.
    */
function payBackLoan(uint32 _loanId) external {
}
```

### X2Y2

```
/**
    * @dev Public function for anyone to repay a loan, and return the NFT token to origin borrower.
    * @param _loanId  The loan Id.
    */
function repay(uint32 _loanId) public {
}
```

### X2Y2 V3

```
function repay(uint32 _loanId) public {
}
```

### Blur
