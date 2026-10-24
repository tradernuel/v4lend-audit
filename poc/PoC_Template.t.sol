// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Drop this file into the target repo at test/poc/ and run with:
//   MAINNET_RPC_URL=<rpc> forge test --match-path 'test/poc/*' -vvv
//
// Template for a Cantina PoC. A valid submission needs a coded test that
// demonstrates the High/Medium impact against the in-scope code at commit
// f6d0fb41b7487f60ce64e011312a956e184e2a75. Reuse the repo's own harness
// (test/utils/BaseTest.sol, Deployers.sol, MockV4Oracle) wherever possible.

import {BaseTest} from "test/utils/BaseTest.sol";

contract PoC is BaseTest {
    function setUp() public {
        // deployArtifactsAndLabel();
        // ... build the minimal pool/vault/hook stack that reproduces the issue
    }

    function test_poc() public {
        // 1. arrange the vulnerable state
        // 2. perform the attacker action
        // 3. assert the invariant break (loss of funds, bad debt, stuck funds, etc.)
    }
}
