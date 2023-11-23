/**
 * Created by Pragma Labs
 * SPDX-License-Identifier: BUSL-1.1
 */
pragma solidity 0.8.19;

import { Registry_Fuzz_Test, RegistryErrors } from "./_Registry.fuzz.t.sol";

/**
 * @notice Fuzz tests for the function "addAsset" of contract "Registry".
 */
contract AddAsset_Registry_Fuzz_Test is Registry_Fuzz_Test {
    /* ///////////////////////////////////////////////////////////////
                              SETUP
    /////////////////////////////////////////////////////////////// */

    function setUp() public override {
        Registry_Fuzz_Test.setUp();
    }

    /*//////////////////////////////////////////////////////////////
                              TESTS
    //////////////////////////////////////////////////////////////*/
    function testFuzz_Revert_addAsset_NonAssetModule(address unprivilegedAddress_, address asset) public {
        // Given: unprivilegedAddress_ is not address(erc20AssetModule), address(floorERC721AssetModule) or address(floorERC1155AssetModule)
        vm.assume(unprivilegedAddress_ != address(erc20AssetModule));
        vm.assume(unprivilegedAddress_ != address(floorERC721AssetModule));
        vm.assume(unprivilegedAddress_ != address(floorERC1155AssetModule));
        vm.startPrank(unprivilegedAddress_);
        // When: unprivilegedAddress_ calls addAsset
        // Then: addAsset should revert with RegistryErrors.Only_AssetModule.selector
        vm.expectRevert(RegistryErrors.Only_AssetModule.selector);
        registryExtension.addAsset(asset);
        vm.stopPrank();
    }

    function testFuzz_Revert_addAsset_OverwriteAsset() public {
        // Given: erc20AssetModule has token1 added as asset

        vm.startPrank(address(floorERC721AssetModule));
        // When: floorERC721AssetModule calls addAsset
        // Then: addAsset should revert with RegistryErrors.Asset_Already_In_Registry.selector
        vm.expectRevert(RegistryErrors.Asset_Already_In_Registry.selector);
        registryExtension.addAsset(address(mockERC20.token1));
        vm.stopPrank();
    }

    function testFuzz_Success_addAsset(address newAsset) public {
        vm.assume(registryExtension.inRegistry(newAsset) == false);
        // When: erc20AssetModule calls addAsset with input of address(eth)
        vm.startPrank(address(erc20AssetModule));
        vm.expectEmit();
        emit AssetAdded(newAsset, address(erc20AssetModule));
        registryExtension.addAsset(newAsset);
        vm.stopPrank();

        // Then: inRegistry for address(eth) should return true
        assertTrue(registryExtension.inRegistry(newAsset));
        address assetModule = registryExtension.assetToAssetModule(newAsset);
        assertEq(assetModule, address(erc20AssetModule));
    }
}
