pragma solidity ^0.4.15;
import './TokenOrder.sol';

contract Product is Ownable {
  mapping (address => uint) public prices;
  uint public totalQuantity;
  uint public productID;
  bool public active;

  event LogOrder(address _order, uint indexed _productID, address indexed _seller, address indexed _buyer, address _token, uint _quantity);

  function Product(uint _totalQuantity, uint _productID, address _seller) {
    productID = _productID;
    totalQuantity = _totalQuantity;
    owner = _seller;
  }

  function setProductID(uint _productID) onlyOwner returns (bool success) {
    productID = _productID;
    return true;
  }

  function setPrice(ERC20 _token, uint _amount) onlyOwner {
    prices[_token] = _amount;
  }

  function setQuantity(uint _totalQuantity) onlyOwner {
    totalQuantity = _totalQuantity;
  }

  function placeOrder(address _token, uint _quantity) returns (Order order) {
    uint pricePerUnit = prices[_token];
    require(pricePerUnit > 0);
    if (_token == 0x0) {
      // Todo ETH payment
    } else {
      order = new TokenOrder(this, owner, msg.sender, ERC20(_token), pricePerUnit * _quantity);
    }
    totalQuantity--;
    LogOrder(order, productID, owner, msg.sender, _token, _quantity);
  }
}
