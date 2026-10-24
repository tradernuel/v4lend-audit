# Context / prior review

- Repo already went through Cantina Scan #1 (56 findings, V4LE-1..77) and Scan #2 (37 findings,
  V4LE-89..156). See docs/audit-*.md in the target repo. Anything matching a V4LE id is a known issue.
- Accepted risks (out of scope): whole-balance sweep model, AutoLend holding shares, no hook swap
  slippage floor, non-vault remint losing automation, reserve-backed liquidation subsidy (V4LE-18/91),
  JIT capture of donate-based drips (V4LE-99), debt drifting above caps via interest (V4LE-87),
  controller drip sync ordering, zero TWAP window = spot.
- Trusted: vault owner, hook owner, automator operators, allowlisted transformers.
- Out of scope: MEV / frontrunning / gas griefing.
