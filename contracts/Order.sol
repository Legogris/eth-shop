pragma solidity ^0.4.15;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';

contract Order {
  function withdrawPayment() returns (bool);
  function remainingAmount() constant returns (uint);
}
