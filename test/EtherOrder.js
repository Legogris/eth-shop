const EtherOrder = artifacts.require("./EtherOrder.sol");
const Product = artifacts.require("./Product.sol");

contract('EtherOrder', (accounts) => {
  let product;
  let order;
  const buyer = accounts[1];
  const seller = accounts[0];
  const price = web3.toWei(1, 'ether');
  // beforeEach(() => Product.new(10, 1, accounts[0]).then(instance => { product = instance; }));

  it("should mark as fully funded after one exact payment", () => {
    return Product.new(10, 1, seller)
    .then(instance => { product = instance; return EtherOrder.new(product.contract.address, seller, buyer, price); })
    .then(instance => {
      order = instance;
      return instance.send(price, { from: buyer });
    })
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), '0')
    });
  });

  it("should mark as fully funded after two separate payments", () => {
    return Product.new(10, 1, seller)
    .then(instance => {
      product = instance;
      return EtherOrder.new(product.contract.address, seller, buyer, price); })
    .then(instance => {
      order = instance;
      return instance.send(web3.toWei(0.5, 'ether'), { from: buyer });
    })
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), web3.toWei('0.5', 'ether'))
      return order.send(web3.toWei(0.5, 'ether'), { from: accounts[2] });
    })
    .then(() => order.remainingAmount())
    .then(result => {
      assert.equal(result.toString(10), '0')
    });
  });
});
