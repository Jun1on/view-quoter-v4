// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {IQuoter} from "./interfaces/IQuoter.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {QuoterMath} from "./libraries/QuoterMath.sol";
import {console} from "lib/forge-std/src/console.sol";
import {BalanceDelta, toBalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

contract Quoter is IQuoter {
    IPoolManager public immutable poolManager;

    constructor(IPoolManager _poolManager) {
        poolManager = _poolManager;
    }

    function quoteExactInputSingle(PoolKey calldata poolKey, IPoolManager.SwapParams calldata swapParams)
        public
        view
        override
        returns (BalanceDelta quote)
    {
        (int256 amount0, int256 amount1, uint160 sqrtPriceAfterX96, uint32 initializedTicksCrossed) =
            QuoterMath.quote(poolManager, poolKey, swapParams);
        console.log("DONE");
        console.logInt(amount0);
        console.logInt(amount1);
        return toBalanceDelta(0, 0);
    }
}
