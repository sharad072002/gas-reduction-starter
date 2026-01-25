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
        nft = new GasOptimized(); // No constructor arguments
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function test_MintGas() public {
        uint256 gasBefore = gasleft();
        nft.mint(user1, 1); // mint(address to, uint256 quantity)
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("mint() gas used:", gasUsed);
        console.log("mint() gas target:", MINT_GAS_TARGET);
        
        // Uncomment when optimized:
        // assertLt(gasUsed, MINT_GAS_TARGET, "mint() exceeds gas target");
    }

    function test_TransferGas() public {
        // First mint
        nft.mint(user1, 1);
        
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
        uint256 gasBefore = gasleft();
        nft.mint(user1, 10); // Batch mint 10 NFTs
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("batchMint(10) gas used:", gasUsed);
        console.log("batchMint(10) gas target:", BATCH_MINT_GAS_TARGET);
        
        // Uncomment when optimized:
        // assertLt(gasUsed, BATCH_MINT_GAS_TARGET, "batchMint() exceeds gas target");
    }

    // Functionality tests (must all pass)
    function test_MintWorks() public {
        nft.mint(user1, 1);
        
        assertEq(nft.ownerOf(1), user1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.totalSupply(), 1);
    }

    function test_TransferWorks() public {
        nft.mint(user1, 1);
        
        vm.prank(user1);
        nft.transfer(user2, 1);
        
        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function test_BatchMintWorks() public {
        nft.mint(user1, 10);
        
        assertEq(nft.totalSupply(), 10);
        assertEq(nft.balanceOf(user1), 10);
        
        for (uint256 i = 1; i <= 10; i++) {
            assertEq(nft.ownerOf(i), user1);
        }
    }
}
