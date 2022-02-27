const TestToken = artifacts.require("TestToken");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(TestToken);

  /* let dex = await Dex.deployed()
  let tst = await TestToken.deployed()
  
  await dex.addToken(web3.utils.fromUtf8("TST"), tst.address)
  await tst.approve(dex.address, 500)
  await dex.deposit(100, web3.utils.fromUtf8("TST"))
  
  let balanceOfTst = await dex.balances(accounts[0], web3.utils.fromUtf8("TST"));
  console.log(balanceOfTst);*/
};
