// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./TestContract.sol";

contract Factory {
    event Deployed(address indexed deployedContract); // Event emitted when a contract is successfully deployed
    event DeploymentFailed(string message); // Event emitted when a contract deployment fails

    /**
     * @notice  A function to deploy a contract and return its address
     * @dev     The function deploys a new contract with the given constructor arguments and a precomputed salt value
     *          The function emits the Deployed event upon successful deployment and emits the DeploymentFailed event upon failure
     * @param   _owner  The address to set as the owner of the newly deployed contract [TestContract constructor argument]
     * @param   _walletname  The name of the wallet to be used by the newly deployed contract [TestContract constructor argument]
     * @param   _salt   A unique uint256 used to precompute an address for the newly deployed contract
     * @return  deployedContract The address of the newly deployed contract
    */
    function createContract(
        address _owner,
        string memory _walletname,
        uint _salt
    ) public payable returns (address deployedContract) {
        bytes32 salted = bytes32(_salt);

        try new TestContract{salt: salted}(_owner, _walletname) returns (address _contractAddress) {
            deployedContract = _contractAddress;
            emit Deployed(deployedContract);
        } catch (bytes memory error) {
            emit DeploymentFailed(string(error));
        }
    }

    /**
     * @notice  A function to compute the address of a contract to be deployed
     * @dev     The function returns the address where a contract will be deployed if deployed with the create2 opcode
     * @param   _salt   A unique uint256 used to precompute an address for the contract to be deployed
     * @param   bytecode The bytecode of the contract to be deployed
     * @return  predictedAddress The predicted address of the contract to be deployed
    */
    function getAddress(uint _salt, bytes memory bytecode) public view returns (address) {
        bytes32 salt = bytes32(_salt);

        address predictedAddress = address(uint160(uint(keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this), 
                salt, 
                keccak256(bytecode) 
            )
        ))));
      
        return predictedAddress;
    }
}
