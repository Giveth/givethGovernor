// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import 'forge-std/console.sol';
import 'forge-std/Script.sol';
import '@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import '@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol';
import 'src/GivethGovernor.sol';
import 'src/VotingToken.sol';

contract deployRelayer is Script {

    TestVotingToken votingToken;
    GivethGovernor implementation;
    GivethGovernor givethGovernor;
    ProxyAdmin givethGovernorProxyAdmin;
    TransparentUpgradeableProxy givethGovernorProxy;

    // token distro address
    address tokenDistro = 0x8D2cBce8ea0256bFFBa6fa4bf7CEC46a1d9b43f6;
    // admin of contract who is allowed to add batchers
    // address givethMultiSig = 0x4D9339dd97db55e3B9bCBE65dE39fF9c04d1C2cd;
    address deployer = 0xe1ce7720f9b434ec98382f776e5C3A48C8BA6673;
    // address of initial batcher - should be agent or multisig who will be approving sending GIVbacks
    address batcher = 0x06263e1A856B36e073ba7a50D240123411501611;

function run() external {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        
        vm.startBroadcast(deployerPrivateKey);
        votingToken = new TestVotingToken();

        givethGovernorProxyAdmin = new ProxyAdmin();
        // new implementation
        implementation = new GivethGovernor();
        givethGovernorProxy =
        new TransparentUpgradeableProxy(payable(address(implementation)), address(givethGovernorProxyAdmin),
         abi.encodeWithSelector(GivethGovernor(givethGovernor).initialize.selector, votingToken));
        givethGovernor = GivethGovernor(payable(givethGovernorProxy));

        console.log('proxy admin' , address(givethGovernorProxyAdmin));
        console.log('givbacks relayer', address(givethGovernor));
        console.log('givbacks relayer implementation', address(implementation));
}
}