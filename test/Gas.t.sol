// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NFTMarket.sol";

contract GasTest is Test {
    GasOptimized public nft;
    address public user1;
    address public user2;

    // Gas targets
    uint256 constant MINT_GAS_TARGET = 45000;
    uint256 constant TRANSFER_GAS_TARGET = 35000;
    uint256 constant BATCH_MINT_GAS_TARGET = 80000;

    function setUp() public {
        nft = new GasOptimized("TestNFT", "TNFT");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function test_MintGas() public {
        vm.prank(user1);
        uint256 gasBefore = gasleft();
        nft.mint{value: 0.01 ether}();
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("mint() gas used:", gasUsed);
        console.log("mint() gas target:", MINT_GAS_TARGET);
        
        // Uncomment when optimized:
        // assertLt(gasUsed, MINT_GAS_TARGET, "mint() exceeds gas target");
    }

    function test_TransferGas() public {
        // First mint
        vm.prank(user1);
        nft.mint{value: 0.01 ether}();
        
        // Measure transfer
        vm.prank(user1);
        uint256 gasBefore = gasleft();
        nft.transfer(user2, 1);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("transfer() gas used:", gasUsed);
        console.log("transfer() gas target:", TRANSFER_GAS_TARGET);
        
        // Uncomment when optimized:
        // assertLt(gasUsed, TRANSFER_GAS_TARGET, "transfer() exceeds gas target");
    }

    function test_BatchMintGas() public {
        vm.prank(user1);
        uint256 gasBefore = gasleft();
        nft.batchMint{value: 0.1 ether}(10);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("batchMint(10) gas used:", gasUsed);
        console.log("batchMint(10) gas target:", BATCH_MINT_GAS_TARGET);
        
        // Uncomment when optimized:
        // assertLt(gasUsed, BATCH_MINT_GAS_TARGET, "batchMint() exceeds gas target");
    }

    // Functionality tests (must all pass)
    function test_MintWorks() public {
        vm.prank(user1);
        nft.mint{value: 0.01 ether}();
        
        assertEq(nft.ownerOf(1), user1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.totalSupply(), 1);
    }

    function test_TransferWorks() public {
        vm.prank(user1);
        nft.mint{value: 0.01 ether}();
        
        vm.prank(user1);
        nft.transfer(user2, 1);
        
        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function test_BatchMintWorks() public {
        vm.prank(user1);
        nft.batchMint{value: 0.1 ether}(10);
        
        assertEq(nft.totalSupply(), 10);
        assertEq(nft.balanceOf(user1), 10);
        
        for (uint256 i = 1; i <= 10; i++) {
            assertEq(nft.ownerOf(i), user1);
        }
    }
}
