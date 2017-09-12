pragma solidity ^0.4.15;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';

contract Order {

  event LogOrderFunded(address _source, address _sender, uint _amount, uint _totalPaid);
  event LogOrderFullyFunded(address _sender);
  event LogWithdraw(address _sender, uint _amount);

  function withdrawPayment() returns (bool);
  function remainingAmount() constant returns (uint);
}
