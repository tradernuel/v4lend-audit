# Review log — v4lend @ f6d0fb4

Status: manual read of all primary in-scope files done once. Build (via_ir) running; PoCs pending build.
Nothing confirmed yet — every lead below still needs a coded PoC before it can be a finding.

## Files read
- vault/V4Vault.sol (full), V4VaultPositionActions.sol
- oracle/V4Oracle.sol (full)
- hook: RevertHook, State, Base, Access, LookupBase, Config, Execution, ActionBase,
  PositionActions, SwapActions, Immediate, Triggers, Callbacks; HookAuctionController (full)
- vault/transformers: Transformer, V4Utils, LeverageTransformer (full)

## Still to read closely
- shared/math/LiquidityCalculator.sol (1274 lines) — solver domain, V4LE-33/85/89 area
- shared/planning/* (AutoRangeLib, AutoLeverageLib, AutoLendLib)
- shared/swap/Swapper.sol, shared/FeeFirstRemovalLib.sol, NativeAssetLib.sol
- automators/* (AutoExit, AutoRange, AutoCollect, AutoLend, AutoLeverage, Automator, AuctionArbExecutor)
- hook/HookLeaseController.sol, HookFeeController.sol, HookRouteController.sol
- hook/RevertHookAutoLendActions.sol (full), RevertHookAutoLeverageActions.sol, RevertHookMigrationActions.sol
- vault/liquidation/FlashloanLiquidator.sol, LiquidationEscrow.sol
- oracle math corners (TWAP alias, extreme tick) — mostly covered by prior scans

## Leads to probe with a PoC (unconfirmed)

L1. autoCollect reward path (RevertHookPositionActions._payCollectRewards):
    `autoCollect` is permissionless; caller gets 1% of collected fees (reward0/1). AUTO_COLLECT-mode
    swaps are oracle-price-checked, so the fee value is bounded. Check: can a caller repeatedly call
    autoCollect on the same position across blocks to harvest 1% each time with no cooldown? There is
    a `lastCollect` field in PositionState that appears UNUSED in the collect path — is there meant to
    be a min-interval gate? If fees accrue slowly, 1% per call is tiny; but no cooldown means griefing
    a position's compounding by forcing collect+swap repeatedly (MEV/grief — likely out of scope).
    Lower priority.

L2. `_settledLentAssets` / daily-limit interaction with socialized-loss writedown:
    `_handleReserveLiquidation` caps `dailyLendIncreaseLimitLeft` after a writedown, but does NOT
    reduce `dailyLendNetInflow`. After a same-day deposit then a socialized loss, net inflow still
    counts settled supply as lent-at-old-rate. Probably benign (bounds only widen next day) but worth
    a quick check that concentration cap can't be gamed around a writedown.

L3. Liquidation `_sendPositionValue` cap uses oracle prices `price0X96/price1X96` returned from
    `getLiquidityForValue`; the "receivedValue > base -> base = receivedValue" branch gives the LIQUIDATOR
    only `liquidationValue/base` share, remainder to owner. Confirm a hook auction-drip donated to the
    position mid-removal (credited to liquidity being removed) is carried to owner not liquidator — the
    doc claims so (L-02). Try to construct a case where rounding sends >liquidationValue to liquidator.

L4. `transferLoan` carries the hook transform approval to new owner but NOT other operator approvals.
    Combined with `approveTransform` approvals persisting across remove()/re-add() (documented), check
    whether a stale approval + re-deposit of same tokenId by a DIFFERENT owner reactivates a prior
    owner's operator. tokenOwner check in approveTransform keys by msg.sender, and transform() checks
    transformApprovals[loanOwner][tokenId][msg.sender]; loanOwner is current. A prior owner's approval
    sits under prior-owner key, so a new owner is unaffected. Looks safe; recorded as a dead-end lead.

L5. Oracle `_quoteTokenPrice`: when quoting in a token that is neither currency0/1, it calls
    `_getReferenceTokenPriceX96(token, state.cachedChainlinkReferencePriceX96)`. The cached ref price
    came from currency0's read. If the quote token uses a different chainlink reference path, is reuse
    of the cache valid? V4LE-55 (ref-token identity) says denominator cancels. Likely covered. Dead end.

L6. `V4Utils.onERC721Received` executes against received token then returns it to `from`. If the
    position is vault-owned and sent via a path that doesn't set transformedTokenId... but vault never
    sends via safeTransferFrom to V4Utils outside transform. Dead end.

## Known-accepted (do not submit) — see 00-context.md
```
