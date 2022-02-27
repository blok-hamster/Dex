const Dex = artifacts.require("Dex")
const TestToken = artifacts.require("TestToken")
const truffleAssert = require('truffle-assertions');

contract("Dex", accounts => {

    it("Should shown an error if Eth balance is low when creating a buy order", async () => {
        let dex = await Dex.deployed()
        let tst = await TestToken.deployed()
       
        await truffleAssert.reverts(
            dex.createLimitOrder(0, web3.utils.fromUtf8("TST"), 10, 1)
        )

        await dex.depositEth({value: 10})
        
        await truffleAssert.passes(
            dex.createLimitOrder(0, web3.utils.fromUtf8("TST"), 10, 1)
        )
    })

    it("should show an error if token balance is to low when creating a SELL order", async () => {
        let dex = await Dex.deployed()
        let tst = await TestToken.deployed()
       
        await truffleAssert.reverts(
            dex.createLimitOrder(1, web3.utils.fromUtf8("TST"), 10, 1)
        )
        
        await dex.addToken(web3.utils.fromUtf8("TST"), tst.address, {from: accounts[0]})
        await tst.approve(dex.address, 1000)
        await dex.deposit(200, web3.utils.fromUtf8("TST"))
        await truffleAssert.passes(
            dex.createLimitOrder(1, web3.utils.fromUtf8("TST"), 10, 1)
        )
    })

    it("The BUY order book should be ordered on price from highest to lowest starting at index 0", async () => {
        let dex = await Dex.deployed()
        let tst = await TestToken.deployed()

        await tst.approve(dex.address, 1000)
        await dex.deposit(1000, web3.utils.fromUtf8("TST"))
        await dex.depositEth({value: 4000})
        await dex.createLimitOrder(0, web3.utils.fromUtf8("TST"), 2, 300)
        await dex.createLimitOrder(0, web3.utils.fromUtf8("TST"), 2, 200)
        await dex.createLimitOrder(0, web3.utils.fromUtf8("TST"), 2, 400)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("TST"), 0);
        assert(orderbook.length > 0);
        console.log(orderbook);
        for(let i = 0; i < orderbook.length - 1; i++){
            assert(orderbook[i].price >= orderbook[i+1].price);
        }
    
    })

    it("The SELL order book should be ordered on price from Lowest to highest starting at index 0", async () => {
        
        let dex = await Dex.deployed()
        let tst = await TestToken.deployed()

        await tst.approve(dex.address, 1000)
        await dex.deposit(1000, web3.utils.fromUtf8("TST"))
        await dex.depositEth({value: 4000})
        await dex.createLimitOrder(1, web3.utils.fromUtf8("TST"), 2, 300)
        await dex.createLimitOrder(1, web3.utils.fromUtf8("TST"), 2, 200)
        await dex.createLimitOrder(1, web3.utils.fromUtf8("TST"), 2, 400)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("TST"), 1);
        assert(orderbook.length > 0);

        for(let i = 0; i < orderbook.length - 1; i++){
            assert(orderbook[i].price <= orderbook[i+1].price);
        } 
    })


})

