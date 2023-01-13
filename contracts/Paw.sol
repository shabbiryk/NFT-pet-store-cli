pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Paw is ERC20, Ownable {
  uint256 private airDropAmount = 500;

  constructor() ERC20("Paw", "PAW") {
    _mint(msg.sender, 10000000);
  }

  function requestAirdrop() public {
    require(balanceOf(msg.sender) > airDropAmount, "Insufficient balance.");
    airdropTo(msg.sender, airDropAmount);
  }

  function airdropTo(address payable recipient, uint256 amount) private {
    require(transfer(owner(), recipient, amount), "Transfer failed.");
    emit Airdrop(msg.sender, recipient, amount);
  }

  event Airdrop(address indexed sender, address indexed recipient, uint256 amount);
}
