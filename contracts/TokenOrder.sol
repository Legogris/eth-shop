pragma solidity ^0.4.15;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';
import './Order.sol';
import './Product.sol';

contract TokenOrder is Order {
  ERC20 token;
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

  event LogOrderFunded(address _source, address _sender, uint _amount, uint _totalPaid);
  event LogOrderFullyFunded(address _sender);

  function TokenOrder(Product _product, address _seller, address _buyer, ERC20 _token, uint _totalAmount) {
    product = _product;
    seller = _seller;
    buyer = _buyer;
    totalAmount = _totalAmount;
    token = _token;
  }

  function withdrawPayment() returns (bool success) {
    require(msg.sender == seller);
    uint amount = token.balanceOf(this);
    require(amount > 0);
    token.approve(seller, amount);
    return true;
  }

  function remainingAmount() constant returns (uint) {
    if (fundedAmount > totalAmount) {
      return 0;
    }
    return totalAmount - fundedAmount;
  }

  function finalizePayment(address _source) returns (bool success) {
    uint receivedAmount = token.balanceOf(_source);
    require(fundedAmount + receivedAmount > fundedAmount);
    if (!token.transferFrom(_source, this, receivedAmount)) {
      revert();
    }
    fundedAmount += receivedAmount;
    LogOrderFunded(_source, msg.sender, receivedAmount, fundedAmount);
    if (remainingAmount() == 0) {
      LogOrderFullyFunded(msg.sender);
    }
    return true;
  }
}
