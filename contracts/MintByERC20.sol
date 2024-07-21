// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MintByERC20 is ERC721A, Ownable {

    // config
    constructor(address initialOwner)
        ERC721A("Mint By ERC20", "MBERC20")
        Ownable(initialOwner) {
    }
    uint256 public MAX_SUPPLY = 10_000;
    uint256 public MAX_MINT_PER_WALLET = 10;
    uint256 public START_ID = 1;

    bool public mintEnabled = true;
    string public baseURI = "ipfs://bafybeia3xoh2kgd6hhvn5gwk2s7en7fh5jf4gpw4zk5asho4pit4ozzyfu/";
    IERC20 public token;
    uint256 public mintPrice = 1_000_000 * 10**18; // 1M token

    // start token id
    function _startTokenId() internal view virtual override returns (uint256) {
        return START_ID;
    }

    // metadata
    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string.concat(baseURI, Strings.toString(tokenId), ".json");
    }

    // token
    function setToken(address newToken) external onlyOwner {
        token = IERC20(newToken);
    }
    function setMintPrice(uint256 _newMintPrice) external onlyOwner {
        mintPrice = _newMintPrice;
    }
    function withdraw(uint256 amount) external onlyOwner {
        require(token.transfer(msg.sender, amount), "Transfer token failed");
    }

    // toggle sale
    function toggleSale() external onlyOwner {
        mintEnabled = !mintEnabled;
    }

    // mint
    function mint(uint quantity, bytes32[] calldata _merkleProof) external {
        require(mintEnabled, "Sale is not enabled");
        require(_numberMinted(msg.sender) + quantity <= MAX_MINT_PER_WALLET, "Over wallet limit");

        uint256 totalPrice = mintPrice * quantity;
        require(token.balanceOf(msg.sender) >= totalPrice, "Insufficient funds");
        require(token.transferFrom(msg.sender, address(this), totalPrice), "Payment failed");
        
        _checkSupplyAndMint(msg.sender, quantity);
    }
    function adminMint(uint quantity) external onlyOwner {
        _checkSupplyAndMint(msg.sender, quantity);
    }
    function _checkSupplyAndMint(address to, uint256 quantity) private {
        require(_totalMinted() + quantity <= MAX_SUPPLY, "Over supply");

        _mint(to, quantity);
    }

    // aliases
    function numberMinted(address owner) external view returns (uint256) {
        return _numberMinted(owner);
    }
    function remainingSupply() external view returns (uint256) {
        return MAX_SUPPLY - _totalMinted();
    }

}
