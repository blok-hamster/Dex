const Dex = artifacts.require("Dex");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Dex);
};
