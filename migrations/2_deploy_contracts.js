const Shop = artifacts.require("./Shop.sol");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(Shop, accounts[0]);
};
