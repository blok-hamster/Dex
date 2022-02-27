pragma solidity >=0.6.0 <0.8.12;
pragma experimental ABIEncoderV2;

import "./Wallet.sol";

contract Dex is Wallet {

    event LimitOrderCreated(address, Side, bytes32, uint, uint);
    event MarketOrderCreated(address, Side, bytes32, uint);

    using SafeMath for uint;
   
    enum Side {
        BUY,
        SELL
    }

    struct Order{
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
        uint filled;  
    }

    uint nextOrderId;  //  automatically initilized to 0

    /**This mapping takes in an assect and points to amother mapping 
    that takes the uint value for the Side ENUM and points to the Order Struct*/
    mapping(bytes32 => mapping(uint => Order[])) public orderBook;

    function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) public {

        if (side == Side.BUY){
            require(balances[msg.sender]["ETH"] >= amount.mul(price));
        }
        else if(side == Side.SELL){
            require(balances[msg.sender][ticker] > amount);
        }

        Order[] storage orders = orderBook[ticker][uint(side)]; // we just point or refrence the Order[]
        Order(nextOrderId, msg.sender, side, ticker, amount, price, 0);
        orders.push(Order(nextOrderId, msg.sender, side, ticker, amount, price, 0));


        uint i = orders.length > 0 ? orders.length - 1 : 0;
        if(side == Side.BUY){

            while(i > 0){
                if(orders[i - 1].price > orders[i].price){
                    break;
                }
                Order memory orderToMove = orders[i - 1]; // we save the element next to i in memory
                orders[i - 1] = orders[i];                  // then we set the i to the spot nest to it moving from the right 
                orders[i] = orderToMove;              // we then set the value of i ot the orderToMove saved in memory
                i--;
            }
           
        }

        else if(side == Side.SELL){
            
            while(i > 0){
                if(orders[i - 1].price < orders[i].price){
                    break;
                }
                Order memory orderToMove = orders[i - 1]; 
                orders[i - 1] = orders[i];                  
                orders[i] = orderToMove;             
                i--;
            }

        }
        
        nextOrderId++;
        emit LimitOrderCreated(msg.sender, side, ticker, amount, price);
    }

    
    function createMarketOrder(Side side, bytes32 ticker, uint amount) public {
       if(side == Side.SELL){
           require(balances[msg.sender][ticker] >= amount, "Insufficient funds");
       }
        uint orderBookSide;
         /** check the transaction side and set the orderBookSide to 
         opposit of the side */
        if (side == Side.BUY){
            orderBookSide = 1;
        } 
        else if(side == Side.SELL){
            orderBookSide = 0;
        }

        /** create a refrence to the Order[] and pass in the corresponding parameter */
        Order[] storage orders = orderBook[ticker][orderBookSide];


        uint totalFilled; // this tracks how much of the market order has been filled 
        
        /**Create a loop that loops through the orders[],
        and continue to loop as long as totalFilled is */
        for (uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
            uint leftToFill = amount.sub(totalFilled);
            uint availableToFill = orders[i].amount.sub(orders[i].filled);
            uint filled = 0;
            
            if(availableToFill > leftToFill){  // this completly fills the market order
                filled = leftToFill;
            }
            else if(availableToFill <= leftToFill){     // this fill as much as is available to fill orders[i]
                filled = availableToFill;
            }

            totalFilled = totalFilled.add(filled);
            orders[i].filled = orders[i].filled.add(filled);
            uint cost = filled.mul(orders[i].price);

            if(side == Side.BUY){   // Here msg.sender is buyer
                require(balances[msg.sender]["ETH"] >= cost); // this check that the buyer has enough ETH
                balances[msg.sender]["ETH"] -= cost;
                balances[msg.sender][ticker] += filled;
                balances[orders[i].trader][ticker] -= filled;
                balances[orders[i].trader]["ETH"] += cost;    
            }

            else if(side == Side.SELL){     //Here msg.sender is seller
                balances[orders[i].trader]["ETH"] -= cost;
                balances[msg.sender]["ETH"] += cost;
                balances[msg.sender][ticker] -= filled;
                balances[orders[i].trader][ticker] += filled;    
            }


        }

        while(orders.length > 0 && orders[0].filled == orders[0].amount){
            for (uint256 i = 0; i < orders.length - 1; i++) {
                orders[i] = orders[i+1];
            }

            orders.pop();
        }  

        emit MarketOrderCreated(msg.sender, side, ticker, amount);
    }


}
