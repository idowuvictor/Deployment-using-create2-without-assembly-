// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestContract {

    /** State Variable**/
    string public walletName;
    address public admin;

    // Modifier to check for caller of a function. It restrict Access to owner/admin
    modifier onlyAdmin() {
        require(admin == msg.sender, "Caller is not the owner");
        _;
    }

    /** 
    * @notice  constructor .runs on deployemnt of the contract. 
    * @param   _owner  . The Address of the admin/owner,
    * @param   _walletname  . The wallet name 
    **/
    constructor(address _owner, string memory _walletname) payable {
        require(_owner != address(0), "Invalid address");
        require(bytes(_walletname).length > 0, "Invalid wallet name");
        admin = _owner;
        walletName = _walletname;
    }
    
    /**
     * @notice  . A function to transfer ownership to another user
     * @dev     . only admin/owner can call the function
     * @param   _newAdmin  . The Address of the new admin/owner
     */
    function transferOwnership(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }

    /**
     * @notice  . A View Function to get the celo balance of the contract
     * @dev     . returns ether balance of the contract
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice  . A Function to withdraw the celo balance of the contract
     * @dev     . Only admin/owner can call the function
     */
    function withdraw() external onlyAdmin {
        require(address(this).balance > 0, "Insufficient balance");
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    /**
     * @notice  . A Function to receive celo Token sent directly to this contract without a function call.
     * @dev     . similar to a fallback function.
     */
    receive() external payable{
        // do nothing
    }
}
