// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import '../src/Race.sol';

contract RaceTest is Test {
  InSecureum race;

  function setUp() public {
    race = new InSecureum("http://example.xyz");
  }

  function test_uri() public {
    string memory uri = race.uri(0);
    assertEq(uri, "http://example.xyz");
  }

  // testing for incorrect access & underflow attack
  function test_safeTransferFrom() public {
    address alice = address(0x01);
    address bob = address(0x02);
    address crio = address(0x03);
    vm.startPrank(crio);
    // send amount = 1 0-1 => underflow
    race._safeTransferFrom(alice, bob, 0, 1, bytes("11"));
    uint256 fromBalance = race.balanceOf(alice, 0);
    uint256 toBalance = race.balanceOf(bob, 0); 
    console2.log("Alice Balance: ", fromBalance);
    console2.log("Bob Balance: ", toBalance);
    vm.stopPrank();
  }
}