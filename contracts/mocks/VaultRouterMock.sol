// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VaultRouter} from "../core/VaultRouter.sol";
import {ISwapHandler} from "../interfaces/core/ISwapHandler.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {IWETH} from "../interfaces/tokens/IWETH.sol";
import {IV3SwapRouter} from "../interfaces/uniswap/v3/IV3SwapRouter.sol";

contract VaultRouterMock is VaultRouter {
    bytes public callInput;

    constructor() {}

    function swap(
        ISwapHandler.SwapParams memory params
    ) internal override returns (uint256 amountIn, uint256 amountOut) {
        callInput = abi.encode(
            params.underlyingIn,
            params.underlyingOut,
            params.mode,
            params.amountIn,
            params.amountOut,
            params.payload
        );
        return (params.amountIn, params.amountOut);
    }

    function pullToken(IERC20 token, uint256 amount) internal override {
        callInput = abi.encode(token, amount);
    }

    function pushToken(IERC20 token, address to, uint256 amount) internal override {
        callInput = abi.encode(token, to, amount);
    }

    function pullTokenFrom(IERC20 token, address from, uint256 amount) internal override {
        callInput = abi.encode(token, from, amount);
    }

    function pushTokenFrom(IERC20 token, address from, address to, uint256 amount) internal override {
        callInput = abi.encode(token, from, to, amount);
    }

    function sweepTokens(IERC20 token, address to) internal override returns (uint256 amount) {
        callInput = abi.encode(token, to);
        return amount;
    }

    function wrapETH(uint256 amount) internal override {
        callInput = abi.encode(amount);
    }

    function unwrapETH(uint256 amount) internal override {
        callInput = abi.encode(amount);
    }

    function depositVault(IERC4626 vault, uint256 assets, address receiver) internal override returns (uint256 shares) {
        callInput = abi.encode(vault, assets, receiver);
        return shares;
    }

    function mintVault(IERC4626 vault, uint256 shares, address receiver) internal override returns (uint256 assets) {
        callInput = abi.encode(vault, shares, receiver);
        return assets;
    }

    function redeemVault(
        IERC4626 vault,
        uint256 shares,
        address receiver,
        address owner
    ) internal override returns (uint256 assets) {
        callInput = abi.encode(vault, shares, receiver, owner);
        return assets;
    }

    function withdrawVault(
        IERC4626 vault,
        uint256 assets,
        address receiver,
        address owner
    ) internal override returns (uint256 shares) {
        callInput = abi.encode(vault, assets, receiver, owner);
        return shares;
    }

    function pullTokensWithPermit(
        IERC20Permit token,
        uint256 amount,
        address owner,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal override {
        callInput = abi.encode(token, amount, owner, deadline, v, r, s);
    }
}
