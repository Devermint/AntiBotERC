// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { TransactionThrottler } from "../helpers/TransactionThrottler.sol";
import { Ownable } from "../helpers/Ownable.sol";

contract ERC20Mock is ERC20, Ownable, TransactionThrottler {
    uint8 public _decimals;
    address public _bridge;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_,
        uint256 supply
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _mint(msg.sender, supply);
    }

    modifier onlyBridge() {
        require(
            _bridge == msg.sender,
            "only the bridge can trigger this method!"
        );
        _;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override transactionThrottler(sender, recipient) {
        super._transfer(sender, recipient, amount);
    }

    function withdrawERC20(address _tokenAddress, uint256 _amount) public onlyOwner {
        ERC20 token = ERC20(_tokenAddress);
        token.transfer(owner, _amount);
    }

    function setBridge(address bridge) public onlyOwner {
        require(bridge != address(0), "DelegatedMintBurnToken: delegate is the zero address");
        _bridge = bridge;
    }

    function mint(address to, uint256 amount) public onlyBridge(){
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyBridge(){
        _burn(from, amount);
    }
}
