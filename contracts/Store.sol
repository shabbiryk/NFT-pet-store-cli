// contracts/Pet.sol
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Pet.sol";
import "./Paw.sol";

contract Store {

  Paw public token;
  Pet public NFT;

  event Sold(uint256 nftId, uint256 price, address buyer);
  event OnSale(uint256 nftId, uint256 price, address seller);

  address private owner;

  // Keep record for tokenId listed on sale
  mapping(uint256 => bool) public tokenIdForSale;

  mapping(uint256 => address) public nftBuyers;

  // constructor(address tokenAddress, address NFTAddress) {
  constructor(Paw pawaddr, Pet petaddr) {
    // token = Paw(tokenAddress);
    // NFT = Pet(NFTAddress);
    token = pawaddr;
    NFT = petaddr;
  }

  function isOnSale(uint256 _tokenId) public view returns (bool) {
    return tokenIdForSale[_tokenId];
  }

  function tokenPrice(uint256 tokenId) public view returns (uint256 price) {
    price = NFT.tokenPrice(tokenId);
  }

  function nftSale(uint256 _tokenId, uint256 price) external {
    require(msg.sender == NFT.ownerOf(_tokenId), "Only owners can change this status");
    tokenIdForSale[_tokenId] = true;
    NFT.setTokenPrice(_tokenId, price);
    emit OnSale(_tokenId, price, msg.sender);
  }

  function nftMintBuy(uint256 price, string memory tokenURI) external {
    // Require that only the NFT contract owner can call this function.
    require(msg.sender == NFT.owner(), "Only the NFT contract owner can call this function");
    require(token.allowance(msg.sender, address(this)) >= price, "Insufficient allowance");
    require(token.balanceOf(msg.sender) >= price, "Insufficient balance.");

    // Mint the NFT and transfer tokens equal to the NFT's price.
    uint256 tokenId = NFT.mintTo(msg.sender, tokenURI);
    NFT.setTokenPrice(tokenId, price);
    token.transferFrom(msg.sender, address(this), price);

    nftBuyers[tokenId] = msg.sender;
    tokenIdForSale[tokenId] = false;
    emit Sold(tokenId, price, msg.sender);
  }

  function nftBuy(uint256 tokenId) public {
    require(tokenIdForSale[tokenId], "Token must be on sale first");
    uint256 nftPrice = NFT.tokenPrice(tokenId);
    require(token.allowance(msg.sender, NFT.ownerOf(tokenId)) >= nftPrice, "Insufficient allowance.");
    require(token.balanceOf(msg.sender) >= nftPrice, "Insufficient balance.");

    // Transfer Paw token of `nftPrice` amount to the owner of the NFT.
    token.transferFrom(msg.sender, NFT.ownerOf(tokenId), nftPrice);

    // transfer the NFT to the buyer.
    NFT.transferFrom(NFT.ownerOf(tokenId), msg.sender, tokenId);

    nftBuyers[tokenId] = msg.sender;

    // Flip to not for sale.
    tokenIdForSale[tokenId] = false;

    emit Sold(tokenId, nftPrice, msg.sender);
  }
}