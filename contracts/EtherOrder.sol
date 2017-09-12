pragma solidity ^0.4.15;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Order.sol';
import './Product.sol';

contract EtherOrder is Order {
  Product public product;
  address public buyer;
  address public seller;
  uint totalAmount;

  OrderStatuses public status;
  uint public fundedAmount;
  // Can be made enum for having statuses like shipped, dispute open, etc
  enum OrderStatuses { 
    New,
    SellerApproved,
    SellerCancelled,
    Shipped,
    Complete
  }

  function EtherOrder(Product _product, address _seller, address _buyer, uint _totalAmount) {
    product = _product;
    seller = _seller;
    buyer = _buyer;
    totalAmount = _totalAmount;
  }

  function withdrawPayment() returns (bool success) {
    uint amount = this.balance;
    require(msg.sender == seller && amount > 0);
    msg.sender.transfer(amount);
    LogWithdraw(msg.sender, amount);
    return true;
  }

  function remainingAmount() constant returns (uint) {
    if (fundedAmount > totalAmount) {
      return 0;
    }
    return totalAmount - fundedAmount;
  }

  function() payable {
    require(fundedAmount + msg.value > fundedAmount);
    fundedAmount += msg.value;
    LogOrderFunded(msg.sender, msg.sender, msg.value, fundedAmount);
    if (remainingAmount() == 0) {
      LogOrderFullyFunded(msg.sender);
    }
  }
}
