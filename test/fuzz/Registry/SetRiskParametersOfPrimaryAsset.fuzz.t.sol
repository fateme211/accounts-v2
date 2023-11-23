/**
 * Created by Pragma Labs
 * SPDX-License-Identifier: BUSL-1.1
 */
pragma solidity 0.8.19;

import { Registry_Fuzz_Test, RegistryErrors } from "./_Registry.fuzz.t.sol";

import { RiskModule } from "../../../src/RiskModule.sol";
import { PrimaryAssetModule } from "../../../src/asset-modules/AbstractPrimaryAssetModule.sol";

/**
 * @notice Fuzz tests for the function "setRiskParametersOfPrimaryAsset" of contract "Registry".
 */
contract SetRiskParametersOfPrimaryAsset_Registry_Fuzz_Test is Registry_Fuzz_Test {
    /* ///////////////////////////////////////////////////////////////
                              SETUP
    /////////////////////////////////////////////////////////////// */

    function setUp() public override {
        Registry_Fuzz_Test.setUp();
    }

    /*//////////////////////////////////////////////////////////////
                              TESTS
    //////////////////////////////////////////////////////////////*/
    function testFuzz_Revert_setRiskParametersOfPrimaryAsset_NonRiskManager(
        address unprivilegedAddress_,
        address asset,
        uint96 assetId,
        uint128 maxExposure,
        uint16 collateralFactor,
        uint16 liquidationFactor
    ) public {
        vm.assume(unprivilegedAddress_ != users.riskManager);

        vm.startPrank(unprivilegedAddress_);
        vm.expectRevert(RegistryErrors.Unauthorized.selector);
        registryExtension.setRiskParametersOfPrimaryAsset(
            address(creditorUsd), asset, assetId, maxExposure, collateralFactor, liquidationFactor
        );
        vm.stopPrank();
    }

    function testFuzz_Revert_setRiskParametersOfPrimaryAsset_CollFactorExceedsLiqFactor(
        address asset,
        uint96 assetId,
        uint128 maxExposure,
        uint16 collateralFactor,
        uint16 liquidationFactor
    ) public {
        collateralFactor = uint16(bound(collateralFactor, 1, RiskModule.ONE_4));
        liquidationFactor = uint16(bound(liquidationFactor, 0, collateralFactor - 1));

        registryExtension.setAssetToAssetModule(asset, address(primaryAssetModule));

        vm.prank(users.riskManager);
        vm.expectRevert(PrimaryAssetModule.CollFactorExceedsLiqFactor.selector);
        registryExtension.setRiskParametersOfPrimaryAsset(
            address(creditorUsd), asset, assetId, maxExposure, collateralFactor, liquidationFactor
        );
    }

    function testFuzz_Success_setRiskParametersOfPrimaryAsset(
        address asset,
        uint96 assetId,
        uint128 maxExposure,
        uint16 collateralFactor,
        uint16 liquidationFactor
    ) public {
        collateralFactor = uint16(bound(collateralFactor, 0, RiskModule.ONE_4));
        liquidationFactor = uint16(bound(liquidationFactor, collateralFactor, RiskModule.ONE_4));

        registryExtension.setAssetToAssetModule(asset, address(primaryAssetModule));

        vm.prank(users.riskManager);
        registryExtension.setRiskParametersOfPrimaryAsset(
            address(creditorUsd), asset, assetId, maxExposure, collateralFactor, liquidationFactor
        );

        bytes32 assetKey = bytes32(abi.encodePacked(assetId, asset));
        (, uint128 actualMaxExposure, uint16 actualCollateralFactor, uint16 actualLiquidationFactor) =
            primaryAssetModule.riskParams(address(creditorUsd), assetKey);
        assertEq(actualMaxExposure, maxExposure);
        assertEq(actualCollateralFactor, collateralFactor);
        assertEq(actualLiquidationFactor, liquidationFactor);
    }
}
