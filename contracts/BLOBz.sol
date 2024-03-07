// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BLOBz is ERC20 {
    constructor() ERC20("BLOBz", "BLOBZ") {
        _mint(msg.sender, 484_400_000_000_000 * 10 ** decimals());
    }
}
