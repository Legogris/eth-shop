const TokenOrder = artifacts.require("./TokenOrder.sol");
const Product = artifacts.require("./Product.sol");
const SimpleToken = artifacts.require("./SimpleToken.sol");
// import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract('TokenOrder', (accounts) => {
  let product;
  let order;
  let token;
  const seller = accounts[0];
  const buyer = accounts[1];
  let price = web3.toBigNumber('1000');

  it("should mark as fully funded after one exact payment", () => {
    return SimpleToken.new({ from: buyer })
    .then(instance => {
      token = instance;
      return Product.new(10, 1, seller, token.contract.address, price)
    })
    .then(instance => {
      product = instance;
      return TokenOrder.new(product.contract.address, buyer, token.contract.address, price);
    })
    .then(instance => {
      order = instance;
      return token.approve(order.contract.address, price, { from: buyer });
    })
    .then(() => order.finalizePayment(buyer, { from: buyer }))
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), '0')
    });
  });

  it("should not allow payer to overcharge their token amount", () => {
    const price = '100000'; // more than buyer balance
    return SimpleToken.new({ from: buyer })
    .then(instance => {
      token = instance;
      return Product.new(10, 1, seller, token.contract.address, price)
    })
    .then(instance => {
      product = instance;
      return TokenOrder.new(product.contract.address, buyer, token.contract.address, price);
    })
    .then(instance => {
      order = instance;
      return token.approve(order.contract.address, price, { from: buyer });
    })
    .then(() => order.finalizePayment(buyer, { from: buyer })) // should fail since allowance is bigger than balance
    .then(assert.fail)
    .catch(err => assert.include(err.message, 'invalid opcode', 'should not allow buyer to overcharge their balance'))
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), price);
      return token.balanceOf(order.contract.address);
    })
    .then(result => {
      assert.equal(result.toString(10), '0'); // ensure no funds were actually taken
    });
  });

  it("should mark as fully funded after two separate payments from different people", () => {
    return SimpleToken.new({ from: buyer })
    .then(instance => {
      token = instance;
      return Product.new(10, 1, seller, token.contract.address, price)
    })
    .then(instance => {
      product = instance;
      return TokenOrder.new(product.contract.address, buyer, token.contract.address, price);
    })
    .then(instance => {
      order = instance;
      return token.approve(order.contract.address, web3.toBigNumber('500'), { from: buyer });
    })
    .then(() => token.transfer(accounts[2], web3.toBigNumber('1000'), { from: buyer }))
    .then(() => order.finalizePayment(buyer, { from: buyer }))
    .then(() => {
      return token.approve(order.contract.address, web3.toBigNumber('600'), { from: accounts[2] });
    })
    .then(() => order.finalizePayment(accounts[2], { from: buyer }))
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), '0')
    });
  });

  it("should only allow seller to withdraw", () => {
    return SimpleToken.new({ from: buyer })
    .then(instance => {
      token = instance;
      return Product.new(10, 1, seller, token.contract.address, price)
    })
    .then(instance => {
      product = instance;
      return TokenOrder.new(product.contract.address, buyer, token.contract.address, price);
    })
    .then(instance => {
      order = instance;
      return token.approve(order.contract.address, price, { from: buyer });
    })
    .then(() => order.finalizePayment(buyer, { from: buyer }))
    .then(() => order.withdrawPayment({ from: buyer }))
    .then(assert.fail)
    .catch(err => assert.include(err.message, 'invalid opcode', 'should not allow buyer to withdraw'))
    .then(() => order.withdrawPayment({ from: seller }))
    .then(() => token.transferFrom(order.contract.address, seller, price))
    .then(() => token.balanceOf(seller))
    .then((sellerBalance) => {
      assert.isTrue(sellerBalance.eq(price));
    });
  });
});
