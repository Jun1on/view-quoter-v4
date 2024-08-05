// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {IQuoter} from "./interfaces/IQuoter.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

contract Quoter is IQuoter {
    address public immutable poolManager;

    constructor(address _poolManager) {
        poolManager = _poolManager;
    }

    function quoteExactInputSingle(PoolKey calldata poolKey, IPoolManager.SwapParams calldata swapParams)
        public
        view
        override
        returns (uint256 amountReceived)
    {
        int256 amount0;
        int256 amount1;

        bool zeroForOne = params.tokenIn < params.tokenOut;
        IUniswapV3Pool pool = IUniswapV3Pool(params.pool);

        // we need to pack a few variables to get under the stack limit
        QuoterMath.QuoteParams memory quoteParams = QuoterMath.QuoteParams({
            zeroForOne: zeroForOne,
            fee: params.fee,
            sqrtPriceLimitX96: params.sqrtPriceLimitX96 == 0
                ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                : params.sqrtPriceLimitX96,
            exactInput: false
        });

        (amount0, amount1, sqrtPriceX96After, initializedTicksCrossed) =
            QuoterMath.quote(pool, params.amountIn.toInt256(), quoteParams);

        amountReceived = amount0 > 0 ? uint256(-amount1) : uint256(-amount0);
    }
}
