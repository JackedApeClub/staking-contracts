// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract PumpTokenERC20 is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 _maxStakeYield = 30000000 ether;
    uint256 _currentStakeYield = 0;

    address private _communityRewards = address(0xdef1F61772C793DE0F6D9F897121646C79C1d8F5);
    address private _daoWallet = address(0xdef1F61772C793DE0F6D9F897121646C79C1d8F5);
    address private _teamWallet = address(0xdef1F61772C793DE0F6D9F897121646C79C1d8F5);

    constructor() ERC20("Pump", "PMP") {
        _mint(_communityRewards, _maxStakeYield);
        _mint(_daoWallet, _maxStakeYield);
        _mint(_teamWallet, _maxStakeYield / 3);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public { //onlyRole(MINTER_ROLE)
        require((_currentStakeYield + amount) < _maxStakeYield);
        _mint(to, amount);
        _currentStakeYield += amount;
    }
}