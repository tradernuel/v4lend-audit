// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

// Fork-free PoC scaffold (the session's egress proxy blocks public mainnet RPCs).
// Copy to <v4lend>/test/poc/ and run:
//   forge test --match-path 'test/poc/LocalVaultScaffold.t.sol' -vvv
//
// Builds on the repo's own V4VaultLocalBase: real PoolManager / PositionManager, a hook-less
// pool over two mock tokens, a mock lend asset and a MockV4Oracle whose position value is set
// per test. Use it as the starting point for any vault-side PoC.

import {V4VaultLocalBase} from "test/vault/support/V4VaultLocalBase.sol";

contract LocalVaultScaffoldTest is V4VaultLocalBase {
    function setUp() public override {
        super.setUp();
        _deposit(lender, 100 ether);
    }

    /// Sanity: borrow -> value drop -> third-party liquidation clears the debt and the
    /// vault's books (lent + reserves) stay consistent with its balance.
    function test_scaffold_borrowAndLiquidate() public {
        uint256 tokenId = _createLoan(1e18);
        oracle.setMockPositionValue(10 ether);

        _borrow(tokenId, 8 ether); // 90% CF -> 9 ether capacity
        (uint256 debt,,,,) = vault.loanInfo(tokenId);
        assertEq(debt, 8 ether, "debt after borrow");

        // value drops: collateral 0.9 * 8.85 = 7.965 < 8 (and 8.85 >= 8 * 1.1, so no reserve subsidy)
        oracle.setMockPositionValue(8.85 ether);
        _liquidateAs(liquidator, tokenId, liquidator);

        (uint256 debtAfter,,,,) = vault.loanInfo(tokenId);
        assertEq(debtAfter, 0, "debt cleared");
        assertEq(asset.balanceOf(address(vault)), 100 ether, "vault made whole by liquidator");
    }
}
