const EtherOrder = artifacts.require("./EtherOrder.sol");
const Product = artifacts.require("./Product.sol");

contract('EtherOrder', (accounts) => {
  let product;
  let order;
  const seller = accounts[0];
  const buyer = accounts[1];
  const price = web3.toBigNumber(web3.toWei(1, 'ether'));
  // beforeEach(() => Product.new(10, 1, accounts[0]).then(instance => { product = instance; }));

  it("should mark as fully funded after one exact payment", () => {
    return Product.new(10, 1, seller, '0x0', price)
    .then(instance => { product = instance; return EtherOrder.new(product.contract.address, buyer, price); })
    .then(instance => {
      order = instance;
      return instance.send(price, { from: buyer });
    })
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), '0')
    });
  });

  it("should mark as fully funded after two separate payments from different people", () => {
    return Product.new(10, 1, seller, '0x0', price)
    .then(instance => {
      product = instance;
      return EtherOrder.new(product.contract.address, buyer, price); })
    .then(instance => {
      order = instance;
      return instance.send(web3.toWei(0.5, 'ether'), { from: buyer });
    })
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), web3.toWei('0.5', 'ether'))
      return order.send(web3.toWei(0.6, 'ether'), { from: accounts[2] });
    })
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), '0')
    });
  });

  it("should only allow seller to withdraw", () => {
    let oldSellerBalance = web3.eth.getBalance(seller);
    return Product.new(10, 1, seller, '0x0', price)
    .then(instance => {
      product = instance;
      return EtherOrder.new(product.contract.address, buyer, price); })
    .then(instance => {
      order = instance;
      oldSellerBalance = web3.eth.getBalance(seller);
      return order.sendTransaction({ value: price, from: buyer });
    })
    .then(() => order.withdrawPayment({ from: buyer }))
    .then(assert.fail)
    .catch(err => assert.include(err.message, 'invalid opcode', 'should not allow buyer to withdraw'))
    .then(() => order.withdrawPayment({ from: seller }))
    .then(({tx, receipt }) => {
      const gasCost = web3.eth.getTransaction(tx).gasPrice.mul(receipt.gasUsed);
      const expectedBalance = price.add(oldSellerBalance).sub(gasCost);
      assert.isTrue(web3.eth.getBalance(seller).eq(expectedBalance), 'should have one more ether');
    });
  });
});
