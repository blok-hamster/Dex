pragma solidity >=0.6.0 <0.8.12;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20{

    constructor() ERC20("TestToken", "TST") public {
        _mint(msg.sender, 10000);
    }

}