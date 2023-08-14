// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import 'forge-std/console.sol';
import 'forge-std/Test.sol';
import '@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import '@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol';
import 'src/interfaces/IERC20Bridged.sol';
import 'src/GivethGovernor.sol';
import 'src/VotingToken.sol';
import 'src/TokenDistro.sol';
import 'src/GIVbacksRelayer.sol';
import 'src/interfaces/IDistro.sol';

contract GovernorGivbacks is Test {
    // governor variables
    TestVotingToken votingToken;
    GivethGovernor governorImplementation;
    GivethGovernor givethGovernor;
    ProxyAdmin givethGovernorProxyAdmin;
    TransparentUpgradeableProxy givethGovernorProxy;

    // token distro variables
    TokenDistro tokenDistroImplementation;
    TokenDistro tokenDistro;
    ProxyAdmin tokenDistroProxyAdmin;
    TransparentUpgradeableProxy tokenDistroProxy;
    IDistro distro;
    IERC20Bridged givToken;
    uint256 totalTokens = 2000000000000000000000000000;
    uint256 startTime = 1640361600; 
    uint256 cliffPeriod = 0;
    uint256 duration = 157680000;
    uint256 initialPercentage = 1000;
    bool cancelable = true;



    //givbacks relayer variables
    GIVbacksRelayer givbacksRelayerImplementation;
    ProxyAdmin givbacksRelayerProxyAdmin;
    TransparentUpgradeableProxy givbacksRelayerProxy;
    GIVbacksRelayer givbacksRelayer;
    address deployer = address(1);
    address batcher = address(2);
    address voter = 0x826976d7C600d45FB8287CA1d7c76FC8eb732030;


    function setUp() public {
        vm.startPrank(deployer);
        votingToken = new TestVotingToken();
        votingToken.mint(voter, 1000000000000000000000000000);

        givethGovernorProxyAdmin = new ProxyAdmin();
        // new governor proxy 
        governorImplementation = new GivethGovernor();
        givethGovernorProxy =
        new TransparentUpgradeableProxy(payable(address(governorImplementation)), address(givethGovernorProxyAdmin),
         abi.encodeWithSelector(GivethGovernor(givethGovernor).initialize.selector, votingToken));
        givethGovernor = GivethGovernor(payable(givethGovernorProxy));

        // deploy token distro proxy 
        tokenDistroProxyAdmin = new ProxyAdmin();
        tokenDistroImplementation = new TokenDistro();
        tokenDistroProxy =
        new TransparentUpgradeableProxy(payable(address(tokenDistroImplementation)), address(tokenDistroProxyAdmin),
         abi.encodeWithSelector(TokenDistro(tokenDistro).initialize.selector, totalTokens, startTime, cliffPeriod, duration, initialPercentage, givToken, cancelable));
        tokenDistro = TokenDistro(address(tokenDistroProxy));


        //deploy givbacks relayer 
        givbacksRelayerProxyAdmin = new ProxyAdmin();
        givbacksRelayerImplementation = new GIVbacksRelayer();
        givbacksRelayerProxy =
        new TransparentUpgradeableProxy(payable(address(givbacksRelayerImplementation)), address(givbacksRelayerProxyAdmin),
         abi.encodeWithSelector(GIVbacksRelayer(givbacksRelayer).initialize.selector, tokenDistro, deployer, givethGovernor));
        givbacksRelayer = GIVbacksRelayer(address(givbacksRelayerProxy));

        // setup token distro and relayer
        givToken.mint(address(tokenDistro), totalTokens);
        tokenDistro.grantRole(tokenDistro.DISTRIBUTOR_ROLE(), address(givbacksRelayer));
        tokenDistro.assign(address(givbacksRelayer), totalTokens);

        vm.label( address(givbacksRelayer),'givbacksRelayer');
        vm.label( address(givethGovernor),'givethGovernor');
        vm.label( address(tokenDistro),'tokenDistro');
        vm.label( address(votingToken),'votingToken');
        vm.label( address(givToken),'givToken');
        vm.label( address(givbacksRelayerProxy),'givbacksRelayerProxy');
        vm.label( address(givbacksRelayerImplementation),'givbacksRelayerImplementation');
        vm.label( address(givbacksRelayerProxyAdmin),'givbacksRelayerProxyAdmin');
        vm.label( address(givethGovernorProxy),'givethGovernorProxy');
        vm.label( address(governorImplementation),'givethGovernorImplementation');
        vm.label( address(givethGovernorProxyAdmin),'givethGovernorProxyAdmin');
        vm.label( address(tokenDistroProxy),'tokenDistroProxy');
        vm.label( address(tokenDistroImplementation),'tokenDistroImplementation');
        vm.label( address(tokenDistroProxyAdmin),'tokenDistroProxyAdmin');
        vm.label( address(voter),'voter');
        vm.label( address(batcher),'batcher');
        vm.label( address(deployer),'deployer');

    }

    function testSendingBatch() public {

    }

}