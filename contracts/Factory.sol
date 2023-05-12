// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./TestContract.sol";

contract Factory {
    event Deployed(address indexed deployedContract);

    /**
     * @notice  . A function to Get the address of a contract
     * @dev     . returns an address
     * @param   _owner  . An address[TestContract constructor arguments]
     * @param   _walletname  . A string[TestContract constructor arguments]
     * @param   _salt. A unique uint256 used to precompute an address
    */
    function createContract(
        address _owner,
        string memory _walletname,
        uint _salt
    ) public payable returns (address deployedContract) {
        bytes32 salted = bytes32(_salt);

        deployedContract = address(new TestContract{salt: salted}(_owner, _walletname));

        emit Deployed(deployedContract);
    }


    /**
     * @notice  . A function to Compute address of the contract to be deployed
     * @dev     . returns address where the contract will deployed to if deployed with create2 new opcode
     * @param   _salt: unique uin256 used to precompute an address
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
