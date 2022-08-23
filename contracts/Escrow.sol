// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";

contract Escrow {
    event Create(
        address initiator,
        address depositor,
        address receiver,
        uint256 amount,
        bytes32 id
    );
    event Deposit(address depositer, uint256 amount, bytes32 id);
    event Release(address releaser, bytes32 id);
    event Withdraw(bytes32 id, uint256 amount, address recipient);

    using Counters for Counters.Counter;

    Counters.Counter private _counter;

    struct SimpleTransction {
        address initiator;
        address depositor;
        address receiver;
        uint256 amount;
        bool depositReceived;
        bool depositorRelease;
        bool receiverRelease;
        uint256 deadline;
        bool completed;
    }

    address owner;

    // Hash of counter, initiator and otherParty to their transaction
    mapping(bytes32 => SimpleTransction)
        public transactionIdToSimpleTransaction;

    constructor() {
        owner = msg.sender;
    }

    function createTransaction(
        address _depositor,
        address _receiver,
        uint256 _amount,
        uint256 _deadline
    ) external returns (bytes32) {
        _counter.increment();
        bytes32 id = keccak256(
            abi.encodePacked(_counter.current(), _depositor, _receiver)
        );
        transactionIdToSimpleTransaction[id] = SimpleTransction(
            msg.sender,
            _depositor,
            _receiver,
            _amount,
            false,
            false,
            false,
            block.timestamp + _deadline,
            false
        );
        emit Create(msg.sender, _depositor, _receiver, _amount, id);
        return id;
    }

    function deposit(bytes32 _id) external payable returns (bool) {
        SimpleTransction
            storage currentTransaction = transactionIdToSimpleTransaction[_id];

        require(
            block.timestamp < currentTransaction.deadline,
            "deadline passed"
        );

        require(msg.value == currentTransaction.amount, "invalid amount");
        require(msg.sender == currentTransaction.depositor, "not authorized");

        currentTransaction.depositReceived = true;
        emit Deposit(msg.sender, msg.value, _id);
        return currentTransaction.depositReceived;
    }

    function _compareStringsbyBytes(string memory s1, string memory s2)
        private
        pure
        returns (bool)
    {
        return
            keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    function release(bytes32 _id) external {
        SimpleTransction
            storage currentTransaction = transactionIdToSimpleTransaction[_id];

        require(
            block.timestamp < currentTransaction.deadline,
            "deadline passed"
        );

        if (currentTransaction.depositor == msg.sender) {
            currentTransaction.depositorRelease = true;
        } else if (currentTransaction.receiver == msg.sender) {
            currentTransaction.receiverRelease = true;
        } else {
            revert("invalid sender");
        }
        emit Release(msg.sender, _id);
    }

    function withdraw(bytes32 _id) external {
        SimpleTransction
            storage currentTransaction = transactionIdToSimpleTransaction[_id];

        require(currentTransaction.depositReceived, "deposit not recevied");
        require(!currentTransaction.completed, "already completed");
        require(
            msg.sender == currentTransaction.depositor || msg.sender == currentTransaction.receiver,
            "not authorized"
        );

        if ( msg.sender == currentTransaction.depositor ) {
            require(block.timestamp > currentTransaction.deadline, "too early");
        }
        if ( msg.sender == currentTransaction.receiver ) {
            require(currentTransaction.depositorRelease && currentTransaction.receiverRelease, "not signed off");
        }

        currentTransaction.completed = true;

        (bool success, ) = payable(msg.sender).call{
            value: currentTransaction.amount
        }("");
        require(success, "failed to send ether");
        emit Withdraw(_id, currentTransaction.amount, msg.sender);
    }
}
