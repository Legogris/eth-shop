pragma solidity ^0.4.15;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Order.sol';
import './Product.sol';

contract EtherOrder is Order {
  Product public product;
  address public buyer;
  address public seller;
  uint totalAmount;

  uint public fundedAmount;

  function EtherOrder(Product _product, address _buyer, uint _totalAmount) {
    product = _product;
    seller = product.owner();
    buyer = _buyer;
    totalAmount = _totalAmount;
  }

  function withdrawPayment() returns (bool success) {
    uint amount = this.balance;
    require(msg.sender == seller && amount > 0);
    seller.transfer(amount);
    LogWithdraw(seller, amount);
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
