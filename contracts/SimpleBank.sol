pragma solidity ^0.5.0;


contract SimpleBank {
    // State variables

    // Protect users' balance from other contracts
    mapping(address => uint256) private balances;

    // Track if a user is enrolled
    mapping(address => bool) public enrolled;

    // Owner of the bank
    address public owner;

    // Events - publicize actions to external listeners

    event LogEnrolled(address indexed accountAddress);

    event LogDepositMade(address indexed accountAddress, uint256 amount);

    event LogWithdrawal(
        address indexed accountAddress,
        uint256 withdrawAmount,
        uint256 newBalance
    );

    // Functions

    constructor() public payable {
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
    }

    // Fallback function - Called if other functions don't match call or sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails otherwise, the sender's money is transferred to contract

    function() external payable {
        revert();
    }

    /// @notice Get balance
    /// @return The balance of the user
    // A SPECIAL KEYWORD prevents function from editing state variables;
    // allows function to run locally/off blockchain

    function getBalance() public view returns (uint256) {
        // Get the balance of the sender of this transaction
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event

    function enroll() public returns (bool) {
        enrolled[msg.sender] = true;
        emit LogEnrolled(msg.sender);
        return enrolled[msg.sender];
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // Add the appropriate keyword so that this function can receive ether
    // Use the appropriate global variables to get the transaction sender and value
    // Emit the appropriate event
    // Users should be enrolled before they can make deposits

    function deposit() public payable returns (uint256) {
        /* Add the amount to the user's balance, call the event associated with a deposit,
          then return the balance of the user */

        require(
            enrolled[msg.sender],
            "User is not enrolled and so cannot make a deposit."
        );
        balances[msg.sender] += msg.value;
        emit LogDepositMade(msg.sender, msg.value);
        return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event

    function withdraw(uint256 withdrawAmount) public returns (uint256) {
        // If the sender's balance is at least the amount they want to withdraw,
        // Subtract the amount from the sender's balance, and try to send that amount of ether
        // to the user attempting to withdraw.
        // return the user's balance.

        require(
            balances[msg.sender] >= withdrawAmount,
            "Withdraw amount must be less than or equal to balance."
        );
        balances[msg.sender] -= withdrawAmount;
        msg.sender.transfer(withdrawAmount);
        emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);
        return balances[msg.sender];
    }
}
