# v4lend audit workspace (Cantina competition)

Target: revert-finance/v4lend @ f6d0fb41b7487f60ce64e011312a956e184e2a75
Competition: Cantina, $50k, 6 Oct – 3 Nov 2026. Only High/Medium rewarded; coded PoC mandatory.

## Layout
- `notes/` — per-component review notes and leads (incl. dead ends, so they aren't re-checked)
- `findings/` — candidate write-ups in Cantina format (only after a PoC confirms them)
- `poc/` — Foundry tests to drop into the v4lend repo's `test/` dir

## Setup
    git clone https://github.com/revert-finance/v4lend.git && cd v4lend
    git checkout f6d0fb41b7487f60ce64e011312a956e184e2a75 && git submodule update --init --recursive
    forge build   # via_ir, slow (>10 min)
