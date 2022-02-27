const Dex = artifacts.require("Dex")
const TestToken = artifacts.require("TestToken")
const truffleAssert = require('truffle-assertions');

contract.skip("Dex", accounts => {

    it("should only be possible for owner to add tokens", async () => {
        let dex = await Dex.deployed()
        let tst = await TestToken.deployed()
       
        await truffleAssert.passes(
            dex.addToken(web3.utils.fromUtf8("TST"), tst.address, {from: accounts[0]})
        )
        
        await truffleAssert.reverts(
            dex.addToken(web3.utils.fromUtf8("LINK"), tst.address, {from: accounts[1]})
        )
    })

    it("Should handle deposit correctly", async () => {
        let dex = await Dex.deployed()
        let tst = await TestToken.deployed()
        
        await tst.approve(dex.address, 500);
        await dex.deposit(100, web3.utils.fromUtf8("TST"));
        let balance = await dex.balances(accounts[0], web3.utils.fromUtf8("TST"))
        assert.equal(balance.toNumber(), 100)
        
    })

    it("Should handle faulty withdrawals correctly", async () => {
        let dex = await Dex.deployed()
        let tst = await TestToken.deployed()
        
        await truffleAssert.reverts(dex.withdraw(1000, web3.utils.fromUtf8("TST")))
    })

    it("Should handle correct withdrawals correctly", async () => {
        let dex = await Dex.deployed()
        let tst = await TestToken.deployed()
        
        await truffleAssert.passes(dex.withdraw(100, web3.utils.fromUtf8("TST")))
    })

})