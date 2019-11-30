pragma solidity 0.5.11;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

contract PdexStable is ERC20Mintable, ERC20Detailed {
    string public constant name = 'PdexStable';
    string public constant symbol = 'PDEX';
    uint8 public constant decimals = 18;
    uint public constant supply = 100000000 * (10 ** uint(decimals));
    constructor() public {
        _mint(msg.sender, supply);
    }
}