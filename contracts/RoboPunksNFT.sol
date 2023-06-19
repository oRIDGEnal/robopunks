// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoboPunks is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenURI;
    address public withdrawWalletAddress;
    mapping(address => uint256) public walletMint;

    constructor() payable ERC721("RoboPunks", "RP") {
        mintPrice = 0.02 ether;
        totalSupply = 0; // Total sold
        maxSupply = 1000;
        maxPerWallet = 3;
        // Set withdrawal wallet address
    }

    function setIsPublicMintEnabled(
        bool _isPublicMintEnabled
    ) external onlyOwner {
        isPublicMintEnabled = _isPublicMintEnabled;
    }

    function setBaseTokenUri(string calldata _baseURI) external onlyOwner {
        baseTokenURI = _baseURI;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_exists(_tokenId), "Token does not exist");
        return
            string(
                abi.encodePacked(
                    baseTokenURI,
                    Strings.toString(_tokenId),
                    ".json"
                )
            );
    }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWalletAddress.call{
            value: address(this).balance
        }("");
        require(success, ("Withdrawal failed"));
    }

    function mint(uint256 _quantity) public payable {
        // Checks to do prior to the actual mint
        require(isPublicMintEnabled, "Minting is not currently enabled.");
        require(
            msg.value == _quantity * mintPrice,
            "You have entered an incorrect amount for the quantity you are minting."
        );
        require(totalSupply + _quantity <= maxSupply, "NFTs have sold out");
        require(
            walletMint[msg.sender] + _quantity <= maxPerWallet,
            "You have exceeded the maximum amount of NFTs in this collection allowed in a single wallet."
        );

        // Start the mint
        for (uint256 i = 0; i < _quantity; i++) {
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newTokenId);
        }
    }
}
