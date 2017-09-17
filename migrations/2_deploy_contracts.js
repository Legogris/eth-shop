const Shop = artifacts.require("./Shop.sol");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(Shop, accounts[0])
  .then(() => Shop.deployed())
  .then(shop => {
    return shop.approveVendor(accounts[0])
  })
};
