// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.10;

import 'forge-std/Test.sol';
import 'forge-std/console2.sol';
import '../src/Race.sol';

contract RaceTest is Test {
  InSecureum race;
  address alice = address(0x1);
  address bob = address(0x2);
  address crio = address(0x3);

  function setUp() public {
    race = new InSecureum('TestToken', 'TT');
    race._mint(alice, 1000);
    race._mint(bob, 202);
  }

  function test_balanceOf() public {
    assertEq(race.balanceOf(alice), 1000);
    assertEq(race.balanceOf(bob), 202);
  }

  function test_transfer() public {
    vm.startPrank(alice);
    race.transfer(bob, 100);
    assertEq(race.balanceOf(alice), 900);
    assertEq(race.balanceOf(bob), 302);
    assertEq(race.totalSupply(), 1202);
    vm.stopPrank();
  }

  /* 
    hacker is able to allow spender with amount 
    whereas (s)he own no tokens.
  */
  function test_allowance() public {
    vm.startPrank(crio);
    race.approve(bob, 100);
    assertEq(race.allowance(crio, bob), 100);
    vm.stopPrank();
  }

  /*
    able to transfer amount from any account
  */
  function test_transferFrom() public {
    vm.startPrank(crio);
    race.transferFrom(bob, crio, 2);
    assertEq(race.balanceOf(crio), 2);
    vm.stopPrank();
  }

  function test_transferFrom_underflow() public {
    vm.startPrank(crio);
    race._mint(crio, 2);
    race.transferFrom(crio, bob, 1);
    console2.log(race.balanceOf(crio));
    console2.log(race.allowance(crio, crio));
    vm.stopPrank();
  }

  /*
   wrong logic increaseAllowance
  */
  function testFail_increaseAllowance() public {
    vm.startPrank(bob);
    race.approve(crio, 2); // [bob][crio] = 2
    race.increaseAllowance(crio, 4); // [bob][crio] = 2+4
    // but I suspect actual [bob][crio] = 2 + (2+4) = 8
    assertEq(race.allowance(bob, crio), 6);
    vm.stopPrank();
  }

  /*
   wrong logic decreaseAllowance
  */
  function testFail_decreaseAllowance() public {
    vm.startPrank(bob);
    race.approve(crio, 2); // [bob][crio] = 2
    race.decreaseAllowance(crio, 1);
    // expected allowance 1 suspecting 3
    assertEq(race.allowance(bob, crio), 1);
  }
}