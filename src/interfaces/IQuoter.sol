// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

/// @title Quoter Interface
/// @notice TODO
interface IQuoter {
    /// @notice TODO
    function quoteExactInputSingle(PoolKey calldata poolKey, IPoolManager.SwapParams calldata swapParams)
        external
        view
        returns (int256, int256, uint160, uint32);
}
