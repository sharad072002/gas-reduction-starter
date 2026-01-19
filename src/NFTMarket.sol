// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title NFT Marketplace  
/// @notice A simple NFT with marketplace functionality
/// @dev Maximally gas-optimized with ERC721A-style batch minting
contract NFTMarket {
    error NotOwner();
    error ContractPaused();
    error MaxSupplyReached();
    error InsufficientPayment();
    error InvalidQuantity();
    error ExceedsMaxPerTx();
    error ExceedsMaxSupply();
    error InvalidRecipient();
    error NotListed();
    error PaymentFailed();
    error InvalidPrice();
    error WithdrawFailed();
    error NonexistentToken();

    uint256 public immutable maxSupply;
    uint256 public immutable mintPrice;
    
    address public owner;
    uint48 public totalSupply;
    uint8 private _paused;
    
    string public name;
    string public symbol;
    
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public approvals;
    mapping(uint256 => uint256) public listings;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event Listed(uint256 indexed tokenId, uint256 price);
    event Sold(uint256 indexed tokenId, address buyer, uint256 price);
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        maxSupply = 10000;
        mintPrice = 0.01 ether;
        owner = msg.sender;
    }
    
    function paused() external view returns (bool) {
        return _paused != 0;
    }
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        uint256 supply = totalSupply;
        if (tokenId == 0 || tokenId > supply) revert NonexistentToken();
        
        unchecked {
            for (uint256 curr = tokenId; curr != 0; --curr) {
                address o = _owners[curr];
                if (o != address(0)) return o;
            }
        }
        revert NonexistentToken();
    }
    
    function mint() external payable {
        if (_paused != 0) revert ContractPaused();
        
        uint256 supply = totalSupply;
        if (supply >= maxSupply) revert MaxSupplyReached();
        if (msg.value < mintPrice) revert InsufficientPayment();
        
        unchecked {
            uint256 tokenId = supply + 1;
            totalSupply = uint48(tokenId);
            _owners[tokenId] = msg.sender;
            ++balanceOf[msg.sender];
            emit Transfer(address(0), msg.sender, tokenId);
        }
    }
    
    function batchMint(uint256 quantity) external payable {
        if (_paused != 0) revert ContractPaused();
        if (quantity == 0) revert InvalidQuantity();
        if (quantity > 20) revert ExceedsMaxPerTx();
        
        uint256 supply = totalSupply;
        
        unchecked {
            uint256 newSupply = supply + quantity;
            if (newSupply > maxSupply) revert ExceedsMaxSupply();
            if (msg.value < mintPrice * quantity) revert InsufficientPayment();
            
            address minter = msg.sender;
            uint256 firstId = supply + 1;
            
            totalSupply = uint48(newSupply);
            _owners[firstId] = minter;
            balanceOf[minter] += quantity;
            
            // Assembly emit for minimal loop overhead
            /// @solidity memory-safe-assembly
            assembly {
                // keccak256("Transfer(address,address,uint256)")
                let sig := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
                for { let id := firstId } lt(id, add(firstId, quantity)) { id := add(id, 1) } {
                    log4(0, 0, sig, 0, minter, id)
                }
            }
        }
    }
    
    function transfer(address to, uint256 tokenId) external {
        if (ownerOf(tokenId) != msg.sender) revert NotOwner();
        if (to == address(0)) revert InvalidRecipient();
        
        delete approvals[tokenId];
        
        unchecked {
            --balanceOf[msg.sender];
            ++balanceOf[to];
        }
        
        _owners[tokenId] = to;
        emit Transfer(msg.sender, to, tokenId);
    }
    
    function approve(address to, uint256 tokenId) external {
        if (ownerOf(tokenId) != msg.sender) revert NotOwner();
        approvals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }
    
    function list(uint256 tokenId, uint256 price) external {
        if (ownerOf(tokenId) != msg.sender) revert NotOwner();
        if (price == 0) revert InvalidPrice();
        listings[tokenId] = price;
        emit Listed(tokenId, price);
    }
    
    function buy(uint256 tokenId) external payable {
        uint256 price = listings[tokenId];
        if (price == 0) revert NotListed();
        if (msg.value < price) revert InsufficientPayment();
        
        address seller = ownerOf(tokenId);
        
        unchecked {
            --balanceOf[seller];
            ++balanceOf[msg.sender];
        }
        
        _owners[tokenId] = msg.sender;
        delete listings[tokenId];
        delete approvals[tokenId];
        
        (bool success, ) = seller.call{value: price}("");
        if (!success) revert PaymentFailed();
        
        emit Transfer(seller, msg.sender, tokenId);
        emit Sold(tokenId, msg.sender, price);
    }
    
    function pause() external onlyOwner {
        _paused = 1;
    }
    
    function unpause() external onlyOwner {
        _paused = 0;
    }
    
    function withdraw() external onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        if (!success) revert WithdrawFailed();
    }
}
