// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title NFT Marketplace
/// @notice A simple NFT with marketplace functionality
/// @dev ⚠️ THIS CONTRACT IS NOT GAS OPTIMIZED - OPTIMIZE IT!
contract NFTMarket {
    // ⚠️ Not packed - wastes storage slots
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public mintPrice;
    address public owner;
    bool public paused;
    
    // Mappings
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public approvals;
    mapping(uint256 => uint256) public listings; // tokenId => price
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event Listed(uint256 indexed tokenId, uint256 price);
    event Sold(uint256 indexed tokenId, address buyer, uint256 price);
    
    // ⚠️ Expensive string comparisons in constructor
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        maxSupply = 10000;
        mintPrice = 0.01 ether;
        owner = msg.sender;
        paused = false;
    }
    
    modifier onlyOwner() {
        // ⚠️ Expensive string in require
        require(msg.sender == owner, "NFTMarket: caller is not the owner");
        _;
    }
    
    modifier whenNotPaused() {
        // ⚠️ Expensive string in require
        require(!paused, "NFTMarket: contract is paused");
        _;
    }
    
    /// @notice Mint a new NFT
    /// @dev ⚠️ NOT OPTIMIZED
    function mint() external payable whenNotPaused {
        // ⚠️ Multiple storage reads
        require(totalSupply < maxSupply, "NFTMarket: max supply reached");
        require(msg.value >= mintPrice, "NFTMarket: insufficient payment");
        
        // ⚠️ Could be unchecked
        uint256 tokenId = totalSupply + 1;
        totalSupply = tokenId;
        
        ownerOf[tokenId] = msg.sender;
        balanceOf[msg.sender] = balanceOf[msg.sender] + 1;
        
        emit Transfer(address(0), msg.sender, tokenId);
    }
    
    /// @notice Batch mint multiple NFTs
    /// @dev ⚠️ VERY EXPENSIVE - Optimize this!
    function batchMint(uint256 quantity) external payable whenNotPaused {
        require(quantity > 0, "NFTMarket: quantity must be > 0");
        require(quantity <= 20, "NFTMarket: max 20 per tx");
        require(totalSupply + quantity <= maxSupply, "NFTMarket: exceeds max supply");
        require(msg.value >= mintPrice * quantity, "NFTMarket: insufficient payment");
        
        // ⚠️ Loop with storage writes each iteration
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply + 1;
            totalSupply = tokenId;
            ownerOf[tokenId] = msg.sender;
            balanceOf[msg.sender] = balanceOf[msg.sender] + 1;
            emit Transfer(address(0), msg.sender, tokenId);
        }
    }
    
    /// @notice Transfer an NFT
    /// @dev ⚠️ NOT OPTIMIZED
    function transfer(address to, uint256 tokenId) external {
        // ⚠️ Multiple storage reads of same value
        require(ownerOf[tokenId] == msg.sender, "NFTMarket: not owner");
        require(to != address(0), "NFTMarket: invalid recipient");
        
        // Clear approval
        if (approvals[tokenId] != address(0)) {
            approvals[tokenId] = address(0);
        }
        
        // ⚠️ Could be unchecked
        balanceOf[msg.sender] = balanceOf[msg.sender] - 1;
        balanceOf[to] = balanceOf[to] + 1;
        ownerOf[tokenId] = to;
        
        emit Transfer(msg.sender, to, tokenId);
    }
    
    /// @notice Approve another address to transfer
    function approve(address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "NFTMarket: not owner");
        approvals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }
    
    /// @notice List NFT for sale
    function list(uint256 tokenId, uint256 price) external {
        require(ownerOf[tokenId] == msg.sender, "NFTMarket: not owner");
        require(price > 0, "NFTMarket: price must be > 0");
        listings[tokenId] = price;
        emit Listed(tokenId, price);
    }
    
    /// @notice Buy a listed NFT
    function buy(uint256 tokenId) external payable {
        uint256 price = listings[tokenId];
        require(price > 0, "NFTMarket: not listed");
        require(msg.value >= price, "NFTMarket: insufficient payment");
        
        address seller = ownerOf[tokenId];
        
        // Transfer NFT
        balanceOf[seller] = balanceOf[seller] - 1;
        balanceOf[msg.sender] = balanceOf[msg.sender] + 1;
        ownerOf[tokenId] = msg.sender;
        listings[tokenId] = 0;
        approvals[tokenId] = address(0);
        
        // Pay seller
        (bool success, ) = seller.call{value: price}("");
        require(success, "NFTMarket: payment failed");
        
        emit Transfer(seller, msg.sender, tokenId);
        emit Sold(tokenId, msg.sender, price);
    }
    
    /// @notice Pause the contract
    function pause() external onlyOwner {
        paused = true;
    }
    
    /// @notice Unpause the contract
    function unpause() external onlyOwner {
        paused = false;
    }
    
    /// @notice Withdraw contract balance
    function withdraw() external onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "NFTMarket: withdraw failed");
    }
}
