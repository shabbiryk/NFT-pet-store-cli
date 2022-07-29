/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Paw is ERC20, Ownable {

  uint256 private airDropAmount = 500;

  constructor() ERC20("Paw", "PAW") {
    _mint(msg.sender, 10000000);
  }

  function requestAirdrop() public {
    airdropTo(msg.sender, airDropAmount);
  }

  function airdropTo(address recipient, uint256 amount)
    private
  {
    _transfer(owner(), recipient, amount);
  }
}