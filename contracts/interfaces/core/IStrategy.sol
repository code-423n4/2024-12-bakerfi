// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {IOracle} from "./IOracle.sol";

/**
 * @title Strategy Inteface to deploy and ERC-20 on an investment strategy
 *
 * @author Chef Kenji <chef.kenji@bakerfi.xyz>
 * @author Chef Kal-EL <chef.kal-el@bakerfi.xyz>
 *
 * @notice Deploys an Any Standard ERC-20 and harvests yield
 */
interface IStrategy {
    /**
     * @dev Emitted when a strategy is deployed.
     *
     * This event provides information about the address deploying the strategy and the deployed amount.
     *
     * @param from The address deploying the strategy.
     * @param amount The amount deployed in the strategy.
     */
    event StrategyDeploy(address indexed from, uint256 indexed amount);

    /**
     * @dev Emitted when a strategy is undeployed.
     *
     * This event provides information about the address undeploying the strategy and the undeployed amount.
     *
     * @param from The address undeploying the strategy.
     * @param amount The amount undeployed from the strategy.
     */
    event StrategyUndeploy(address indexed from, uint256 indexed amount);

    /**
     * @dev Emitted when a strategy generates a profit.
     *
     * This event provides information about the profit amount generated by the strategy.
     *
     * @param amount The profit amount generated by the strategy.
     */
    event StrategyProfit(uint256 indexed amount);

    /**
     * @dev Emitted when a strategy incurs a loss.
     *
     * This event provides information about the loss amount incurred by the strategy.
     *
     * @param amount The loss amount incurred by the strategy.
     */
    event StrategyLoss(uint256 indexed amount);

    /**
     * @dev Emitted when a strategy's deployed amount is updated.
     *
     * This event provides information about the new deployment amount of the strategy.
     *
     * @param newDeployment The new deployment amount of the strategy.
     */
    event StrategyAmountUpdate(uint256 indexed newDeployment);

    /**
     * @dev Deploys funds in the AAVEv3 strategy
     *
     * @return deployedAmount The amount deployed in the AAVEv3 strategy after leveraging.
     *
     */
    function deploy(uint256 amount) external returns (uint256 deployedAmount);

    /**
     * @notice Harvests the strategy by yield and rebalances the strategy
     *
     * @return balanceChange The change in strategy balance as an int256 value.
     */
    function harvest() external returns (int256 balanceChange);

    /**
     * @dev Initiates the undeployment process by adjusting the contract's position and performing a flash loan.
     *
     * @param amount The amount of ETH to undeploy.
     * @return undeployedAmount The actual undeployed amount of ETH.
     */
    function undeploy(uint256 amount) external returns (uint256 undeployedAmount);

    /**
     * @dev Retrieves the total owned assets by the Strategy in
     *
     * @return assets The total owned assets in the strategy.
     */
    function totalAssets() external view returns (uint256 assets);

    /**
     * The Asset deployed on this strategy
     */
    function asset() external view returns (address);
}
