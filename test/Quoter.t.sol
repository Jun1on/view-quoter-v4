// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {Quoter} from "../src/Quoter.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {TestERC20} from "@uniswap/v4-core/src/test/TestERC20.sol";
import {HookEnabledSwapRouter} from "./utils/HookEnabledSwapRouter.sol";
import {Currency} from "lib/v4-core/src/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IHooks} from "lib/v4-core/src/interfaces/IHooks.sol";
import {BalanceDelta} from "lib/v4-core/src/types/BalanceDelta.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";

contract QuoterTest is Test, Deployers {
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;

    Quoter public quoter;
    HookEnabledSwapRouter router;
    TestERC20 token0;
    TestERC20 token1;

    PoolId id;

    function setUp() public {
        deployFreshManagerAndRouters();
        (currency0, currency1) = deployMintAndApprove2Currencies();

        router = new HookEnabledSwapRouter(manager);
        token0 = TestERC20(Currency.unwrap(currency0));
        token1 = TestERC20(Currency.unwrap(currency1));

        token0.approve(address(router), type(uint256).max);
        token1.approve(address(router), type(uint256).max);

        (key, id) = initPoolAndAddLiquidity(currency0, currency1, IHooks(address(0)), 100, SQRT_PRICE_1_1, ZERO_BYTES);

        quoter = new Quoter(manager);
    }

    function testQuote() public {
        (,,, uint32 initializedTicksCrossed) = _quote(true, 0.001 ether);
        assertEq(initializedTicksCrossed, 1);
        _quote(true, -0.001 ether);
        _quote(false, 0.001 ether);
        _quote(false, -0.001 ether);
    }

    function testLargeQuote() public {
        (int256 amount0, int256 amount1,, uint32 initializedTicksCrossed) = _quote(true, 1 ether);
        assertEq(initializedTicksCrossed, 2);
        // (int256 secondAmount0, int256 secondAmount1,, uint32 secondInitializedTicksCrossed) = _quote(true, -1 ether);
        // assertEq(secondInitializedTicksCrossed, 2);
    }

    function _quote(bool zeroForOne, int256 amount)
        internal
        returns (int256 amount0, int256 amount1, uint160 sqrtPriceAfterX96, uint32 initializedTicksCrossed)
    {
        uint160 sqrtPriceLimitX96 = zeroForOne ? MIN_PRICE_LIMIT : MAX_PRICE_LIMIT;
        (amount0, amount1, sqrtPriceAfterX96, initializedTicksCrossed) =
            quoter.quoteExactInputSingle(key, IPoolManager.SwapParams(zeroForOne, amount, sqrtPriceLimitX96));
        BalanceDelta swapDelta = swap(key, zeroForOne, amount, ZERO_BYTES);
        (uint160 realSqrtPriceX96,,,) = manager.getSlot0(id);
        assertEq(swapDelta.amount0(), amount0);
        assertEq(swapDelta.amount1(), amount1);
        assertEq(sqrtPriceAfterX96, realSqrtPriceX96);
    }
}
