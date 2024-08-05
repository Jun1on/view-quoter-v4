// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Quoter} from "../src/Quoter.sol";

contract QuoterTest is Test {
    Quoter public quoter;

    function setUp() public {
        quoter = new Quoter();
        quoter.setNumber(0);
    }

    function test_Increment() public {
        quoter.increment();
        assertEq(quoter.number(), 1);
    }
}
