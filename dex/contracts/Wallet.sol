pragma solidity >=0.6.0 <0.8.12;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is Ownable {

    using SafeMath for uint;
    
    struct Token{
        bytes32 ticker;
        address tokenAddress;
    }
    
    bytes32[] tokenList;
    mapping(bytes32 => Token) tokenMap;
    mapping(address => mapping(bytes32 => uint)) public balances;

    modifier tokenExist(bytes32 ticker){
        require(tokenMap[ticker].tokenAddress != address(0), "Token Does Not Exist");
        _;
    }

    function addToken(bytes32 ticker, address tokenAddress) external onlyOwner {
        tokenMap[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint amount, bytes32 ticker) external tokenExist(ticker) {
        balances[msg.sender][ticker] = balances[msg.sender][ticker].add(amount);
        IERC20(tokenMap[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
    }

    function depositEth() payable external {
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].add(msg.value);
    }

    function withdrawEth(uint amount) external {
        require(balances[msg.sender][bytes32("ETH")] >= amount);
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].sub(amount);
        msg.sender.call{value: amount};
    }

    function withdraw(uint amount, bytes32 ticker) external tokenExist(ticker) {
        require(balances[msg.sender][ticker] >= amount, "Balance Not Sufficent");
        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount);
        IERC20(tokenMap[ticker].tokenAddress).transfer(msg.sender, amount);
    }


}