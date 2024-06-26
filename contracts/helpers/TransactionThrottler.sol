// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import { Ownable } from "./Ownable.sol";

contract TransactionThrottler is Ownable {
    bool private _initlialized;
    bool private _restrictionActive;
    uint256 private _tradingStart;
    uint256 private constant _delayBetweenTx = 20;
    mapping(address => bool) private _isWhitelisted;
    mapping(address => bool) private _isUnthrottled;
    mapping(address => uint256) private _previousTx;

    event InitializedAntibot(bool initialized);
    event TradingTimeChanged(uint256 tradingTime);
    event RestrictionActiveChanged(bool active);
    event MarkedWhitelisted(address indexed account, bool isWhitelisted);
    event MarkedUnthrottled(address indexed account, bool isUnthrottled);

    constructor(uint256 tradingStart_) {
        _tradingStart = tradingStart_;
    }

    function initAntibot() external onlyOwner() {
        require(!_initlialized, "Protection: Already initialized");
        _initlialized = true;
        _isUnthrottled[owner] = true;
        _restrictionActive = true;
        emit InitializedAntibot(true);
    }

    function setTradingStart(uint256 _time) external onlyOwner() {
        require(_time > block.timestamp, "Protection: To late");
        _tradingStart = _time;
        emit TradingTimeChanged(_tradingStart);
    }

    function setRestrictionActive(bool _active) external onlyOwner() {
        _restrictionActive = _active;
        emit RestrictionActiveChanged(_restrictionActive);
    }

    function unthrottleAccount(address _account, bool _unthrottled) external onlyOwner() {
        require(_account != address(0), "Zero address");
        _isUnthrottled[_account] = _unthrottled;
        emit MarkedUnthrottled(_account, _unthrottled);
    }

    function isUnthrottled(address account) external view returns (bool) {
        return _isUnthrottled[account];
    }

    function whitelistAccount(address _account, bool _whitelisted) external onlyOwner() {
        require(_account != address(0), "Zero address");
        _isWhitelisted[_account] = _whitelisted;
        emit MarkedWhitelisted(_account, _whitelisted);
    }

    function isWhitelisted(address account) external view returns (bool) {
        return _isWhitelisted[account];
    }

    modifier transactionThrottler(
        address sender,
        address recipient
    ) {
        if (_restrictionActive && !_isUnthrottled[recipient] && !_isUnthrottled[sender]) {
            require(block.timestamp >= _tradingStart, "Protection: Transfers disabled");

            if (!_isWhitelisted[recipient]) {
                require(_previousTx[recipient] + _delayBetweenTx <= block.timestamp, "Protection: 20 sec/tx allowed");
                _previousTx[recipient] = block.timestamp;
            }

            if (!_isWhitelisted[sender]) {
                require(_previousTx[sender] + _delayBetweenTx <= block.timestamp, "Protection: 20 sec/tx allowed");
                _previousTx[sender] = block.timestamp;
            }
        }
        _;
    }
}
