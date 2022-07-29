// contracts/Pet.sol
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Pet is ERC721URIStorage, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Keep record of token value
    mapping(uint256 => uint256) public tokenIdToValue;

    event Minted(uint256 nftId, uint256 price, string tokenURI);

    constructor() ERC721("Pet", "PET") {}

    function exists(uint256 tokenId) view public returns (bool) {
        return _exists(tokenId);
    }

    function currentTokenId() view public returns (uint256) {
        uint256 current = _tokenIds.current();
        if (current == 0) {
            revert("No NFTs have been created.");
        } else {
            return _tokenIds.current() - 1;
        }
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI)
        public
        returns (bool)
    {
        require(msg.sender != address(0));
        require(exists(tokenId));
        _setTokenURI(tokenId, _tokenURI);
        return true;
    }

    function mintTo(address recipient, string memory _tokenURI)
        public
        returns (uint256)
    {
        require(msg.sender != address(0));
        uint256 newItemId = _tokenIds.current();
        tokenIdToValue[newItemId] = 0;
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        _tokenIds.increment();

        emit Minted(newItemId, 0, _tokenURI);

        return newItemId;
    }

    function tokenPrice(uint256 _tokenId) public view returns (uint256) {
        return tokenIdToValue[_tokenId];
    }

    function setTokenPrice(uint256 _tokenId, uint256 price) public {
        tokenIdToValue[_tokenId] = price;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        _beforeTokenTransfer(ownerOf(tokenId), address(0), tokenId);
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId) view public override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        _beforeTokenTransfer(from, to, tokenId);
        super.transferFrom(from, to, tokenId);
    }

}