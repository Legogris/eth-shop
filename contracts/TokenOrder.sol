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

  uint public fundedAmount;

  event LogOrderFunded(address _source, address _sender, uint _amount, uint _totalPaid);
  event LogOrderFullyFunded(address _sender);

  function TokenOrder(Product _product, address _buyer, ERC20 _token, uint _totalAmount) {
    product = _product;
    seller = product.owner();
    buyer = _buyer;
    totalAmount = _totalAmount;
    token = _token;
  }

  function withdrawPayment() returns (bool success) {
    require(msg.sender == seller);
    uint amount = token.balanceOf(this);
    require(amount > 0);
    token.approve(seller, amount);
    LogWithdraw(msg.sender, amount);
    return true;
  }

  function remainingAmount() constant returns (uint) {
    if (fundedAmount > totalAmount) {
      return 0;
    }
    return totalAmount - fundedAmount;
  }

  function finalizePayment(address _source) returns (bool success) {
    uint receivedAmount = token.allowance(_source, this);
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
