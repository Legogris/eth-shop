pragma solidity ^0.4.15;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Product.sol';

contract Shop is Ownable {
  mapping(address => Product[]) public catalogues;
  mapping(address => bool) public vendorsApproved;

  function Shop(address _owner) {
    owner = _owner;
  }

  function addProduct(Product _product) returns (uint productID) {
    require(vendorsApproved[msg.sender]);
    return catalogues[msg.sender].push(_product);
  }

  function approveVendor(address _vendor) onlyOwner returns (bool success) {
    vendorsApproved[_vendor] = true;
    return true;
  }

  function removeVendor(address _vendor) onlyOwner returns (bool success) {
    vendorsApproved[_vendor] = false;
    return true;
  }
}