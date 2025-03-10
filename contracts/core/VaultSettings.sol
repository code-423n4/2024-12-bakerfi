// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {PERCENTAGE_PRECISION} from "./Constants.sol";
import {IVaultSettings} from "../interfaces/core/IVaultSettings.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ADMIN_ROLE} from "./Constants.sol";
/**
 * @title BakerFI Settings(⚙️) Contract
 *
 * @notice The settings could only be changed by the Owner and could be used by any contract by the system.
 *
 * @author Chef Kenji <chef.kenji@bakerfi.xyz>
 * @author Chef Kal-EL <chef.kal-el@bakerfi.xyz>
 *
 * @dev The `Settings` contract is used to manage protocol settings.
 * It extends the `OwnableUpgradeable` contract and implements the `ISettings` interface.
 * The settings can only be changed by the owner and can be utilized by any contract within the system.
 *
 * This contract is going to be used by any service on the Bakerfi system to retrieve
 * the fees, basic configuration parameters and the list of whitelisted adresess that can
 * interact with the system
 */
contract VaultSettings is Initializable, AccessControlUpgradeable, IVaultSettings {
    error InvalidOwner();
    error WhiteListAlreadyEnabled();
    error WhiteListFailedToAdd();
    error WhiteListNotEnabled();
    error WhiteListFailedToRemove();
    error InvalidValue();
    error InvalidPercentage();
    error InvalidMaxLoanToValue();
    error InvalidAddress();

    // Gap before the roles to keep the storage layout consistent with version 1.3
    uint256[103] private __gapBefore;
    // Role definitions

    using EnumerableSet for EnumerableSet.AddressSet;
    /**
     * @dev The withdrawal fee percentage
     *
     * This private state variable holds the withdrawal fee percentage, represented as an integer.
     *
     * Default is 1%
     */
    uint256 private _withdrawalFee; // %

    /**
     * @dev The performance fee percentage.
     *
     * This private state variable holds the performance fee percentage, represented as an integer.
     */
    uint256 private _performanceFee; // 1%

    /**
     * @dev The address of the fee receiver.
     *
     * This private state variable holds the address of the fee receiver.
     * If set to the zero address, there is no fee receiver.
     */
    address private _feeReceiver; // No Fee Receiver
    /**
     * @dev The set of enabled accounts.
     *
     * This private state variable is an EnumerableSet of addresses representing the set of enabled accounts.
     */
    EnumerableSet.AddressSet private _enabledAccounts;

    /**
     * @dev Max Allowed Deposit per Wallet
     */
    uint256 private _maxDeposit;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializes the contract.
     *
     * This function is used for the initial setup of the contract, setting the owner, withdrawal fee,
     * performance fee, fee receiver, loan-to-value ratio, maximum loan-to-value ratio, and the number of loops.
     *
     */
    function _initializeVaultSettings() public onlyInitializing {
        _withdrawalFee = 10 * 1e6; // 1%
        _performanceFee = 10 * 1e6; // 1%
        _feeReceiver = address(0); // No Fee Receiver
        _maxDeposit = 0;
    }

    /**
     * @dev Enables or disables an account in the whitelist.
     *
     * This function can only be called by the owner and is used to enable or disable an account
     * in the whitelist. Emits an {AccountWhiteList} event upon successful update.
     *
     * @param account The address of the account to be enabled or disabled.
     * @param enabled A boolean indicating whether the account should be enabled (true) or disabled (false) in the whitelist.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     */
    function enableAccount(address account, bool enabled) public onlyRole(ADMIN_ROLE) {
        if (enabled) {
            if (_enabledAccounts.contains(account)) revert WhiteListAlreadyEnabled();
            if (!_enabledAccounts.add(account)) revert WhiteListFailedToAdd();
        } else {
            if (!_enabledAccounts.contains(account)) revert WhiteListNotEnabled();
            if (!_enabledAccounts.remove(account)) revert WhiteListFailedToRemove();
        }
        emit AccountWhiteList(account, enabled);
    }

    /**
     * @dev Checks if an account is enabled in the whitelist.
     *
     * This function is externally callable and returns a boolean indicating whether the specified account
     * is enabled in the whitelist.
     *
     * @param account The address of the account to be checked.
     * @return enabled A boolean indicating whether the account is enabled (true) or not (false) in the whitelist.
     */
    function isAccountEnabled(address account) public view returns (bool) {
        return _enabledAccounts.length() == 0 || _enabledAccounts.contains(account);
    }

    /**
     * @dev Sets the withdrawal fee percentage.
     *
     * This function can only be called by the owner and is used to update the withdrawal fee percentage.
     * Emits a {WithdrawalFeeChanged} event upon successful update.
     *
     * @param fee The new withdrawal fee percentage to be set.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     * - The new withdrawal fee percentage must be a valid percentage value.
     */
    function setWithdrawalFee(uint256 fee) public onlyRole(ADMIN_ROLE) {
        if (fee >= PERCENTAGE_PRECISION) revert InvalidPercentage();
        _withdrawalFee = fee;
        emit WithdrawalFeeChanged(_withdrawalFee);
    }

    /**
     * @dev Retrieves the withdrawal fee percentage.
     *
     * This function is externally callable and returns the withdrawal fee percentage.
     *
     * @return fee The withdrawal fee percentage.
     */
    function getWithdrawalFee() public view returns (uint256) {
        return _withdrawalFee;
    }

    /**
     * @dev Sets the performance fee percentage.
     *
     * This function can only be called by the owner and is used to update the performance fee percentage.
     * Emits a {PerformanceFeeChanged} event upon successful update.
     *
     * @param fee The new performance fee percentage to be set.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     * - The new performance fee percentage must be a valid percentage value.
     */
    function setPerformanceFee(uint256 fee) external onlyRole(ADMIN_ROLE) {
        if (fee >= PERCENTAGE_PRECISION) revert InvalidPercentage();
        _performanceFee = fee;
        emit PerformanceFeeChanged(_performanceFee);
    }

    /**
     * @dev Retrieves the performance fee percentage.
     *
     * This function is externally callable and returns the performance fee percentage.
     *
     * @return fee The performance fee percentage.
     */
    function getPerformanceFee() public view returns (uint256) {
        return _performanceFee;
    }
    /**
     * @dev Sets the fee receiver address.
     *
     * This function can only be called by the owner and is used to update the fee receiver address.
     * Emits a {FeeReceiverChanged} event upon successful update.
     *
     * @param receiver The new fee receiver address to be set.
     *
     * Requirements:
     * - The caller must be the owner of the contract.
     * - The new fee receiver address must not be the zero address.
     */
    function setFeeReceiver(address receiver) external onlyRole(ADMIN_ROLE) {
        if (receiver == address(0)) revert InvalidAddress();
        _feeReceiver = receiver;
        emit FeeReceiverChanged(_feeReceiver);
    }

    /**
     * @dev Retrieves the fee receiver address.
     *
     * This function is externally callable and returns the fee receiver address.
     *
     * @return receiver The fee receiver address.
     */
    function getFeeReceiver() public view returns (address) {
        return _feeReceiver;
    }
    /**
     * @notice Retrieves the maximum deposit allowed in ETH.
     * @return The maximum deposit value in ETH.
     */
    function getMaxDeposit() public view returns (uint256) {
        return _maxDeposit;
    }

    /**
     * @notice Sets the maximum deposit allowed in ETH.
     * @param value The maximum deposit value to be set in ETH.
     */
    function setMaxDeposit(uint256 value) external onlyRole(ADMIN_ROLE) {
        _maxDeposit = value;
        emit MaxDepositChanged(value);
    }

    uint256[50] private __gap;
}
