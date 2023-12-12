// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {

    address public arbiter;
    address public beneficiary;

    uint public withdrawalDeadline;
    bool public isCancelled;
    
    mapping(uint => bool) public withdrawalRequests;

    constructor(address _arbiter, address _beneficiary) payable {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        withdrawalDeadline = block.timestamp + 6 weeks;
    }

    function cancel() external {
        if(block.timestamp >= withdrawalDeadline) {
            isCancelled = true;
        }
    }
    
    function withdraw(uint amount) external {
        require(msg.sender == beneficiary, "Only beneficiary");
        require(!isCancelled, "Contract cancelled");
        require(withdrawalRequests[amount] == false, "Already withddrawal");

        (bool sent,) = beneficiary.call{value: amount}("");
        require(sent, "Failed to send Ether");
        
        withdrawalRequests[amount] = true;
    }

    function approve() external {
        require(msg.sender == arbiter, "Only arbiter");
        require(!isCancelled, "Contract cancelled");
        
        uint balance = address(this).balance;
        
        (bool sent,) = beneficiary.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}
