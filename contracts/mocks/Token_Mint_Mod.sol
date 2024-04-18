// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token_Mint_Mod is ERC20, Ownable {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address admin
    ) ERC20(name, symbol) {
        // Mint initial supply to the admin
        _mint(admin, initialSupply);
        // Transfer ownership to the custom admin
        transferOwnership(admin);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}