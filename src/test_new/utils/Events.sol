/**
 * Created by Pragma Labs
 * SPDX-License-Identifier: BUSL-1.1
 */
pragma solidity ^0.8.13;
   
/// @notice Abstract contract containing all the events emitted by the protocol.
abstract contract Events {

    /*//////////////////////////////////////////////////////////////////////////
                                      ERC-721
    //////////////////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    /*//////////////////////////////////////////////////////////////////////////
                                      Factory
    //////////////////////////////////////////////////////////////////////////*/

    event VaultUpgraded(address indexed vaultAddress, uint16 oldVersion, uint16 indexed newVersion);
}   
   
   
   
