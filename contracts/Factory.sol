// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


import "./TestContract.sol";

contract Factory {

    // A mapping to keep track of used salts to prevent reusing them
    mapping(bytes32 => bool) usedSalts;

    event DeployedSuccessfully(address deployedAddress);

    /**
     * @notice  . A function to deploy a contract and return its address
     * @dev     . The function deploys a new contract with the given constructor arguments and a precomputed salt value
     *          The function emits the address of the newly deployed contract upon successful deployment
     * @param   _owner  . An address[TestContract constructor arguments]
     * @param   _walletname  . A string[TestContract constructor arguments]
     * @param   _salt. A unique uint256 used to precompute an address
    */
    function createContract(
        address _owner,
        string memory _walletname,
        uint _salt
    ) public payable {
        bytes32 salted = bytes32(_salt);

        require(!usedSalts[salted], "Salt already used.");
        usedSalts[salted] = true;

        address deployedAddress =  address(new TestContract{salt: salted}(_owner, _walletname));

        emit DeployedSuccessfully(deployedAddress);
    }


    /**
     * @notice  A function to compute the address of a contract to be deployed
     * @dev The function returns the address where a contract will be deployed if deployed with the create2 opcode
     * @param _salt A unique uint256 used to precompute an address.
     * @param _bytecode The bytecode of the contract to be deployed encoded with the parameters.
     */
    function preComputeAddress(uint _salt, bytes memory _bytecode) public view returns (address) {
         bytes32 salt = bytes32(_salt);

        address predictedAddress = address(uint160(uint(keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this), 
                salt, 
                keccak256(_bytecode) 
            )
        ))));
      
        return predictedAddress;
    }
}