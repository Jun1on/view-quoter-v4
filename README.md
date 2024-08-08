## Uniswap v4 view-only quoter

This view-only quoter aims to quote a v4 pool cheaper by removing the revert and the unused state updates. Currently, this can only quote swaps without hook executions that change the output of a swap.

This code is adapted from [view-quoter-v3](https://github.com/Uniswap/view-quoter-v3).