// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/********************
 * @author: Techoshi.eth *
        <(^_^)>
 ********************/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ToothyTooths is Ownable, ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    using ECDSA for bytes32;
    using Strings for uint256;

    Counters.Counter private _tokenSupply;

    uint256 public constant MAX_TOKENS = 3333;
    uint256 public mTL = 20;
    uint256 public whitelistmTL = 20;
    uint256 public tokenPrice = 0.07 ether;
    uint256 public whitelistTokenPrice = 0.055 ether;
    uint256 public maxAfterHoursMissingToothMints = 6000;

    bool public publicMintIsOpen = false;
    bool public privateMintIsOpen = true;
    bool public revealed = false;

    string _baseTokenURI;
    string public baseExtension = ".json";
    string public hiddenMetadataUri;

    address private _MissingToothVault =
        0x0000000000000000000000000000000000000000;

    mapping(address => bool) whitelistedAddresses;

    modifier isWhitelisted(address _address, bytes32 _hash) {
        bool decoy = keccak256(abi.encodePacked("<(^_^)>")) !=
            keccak256(
                abi.encodePacked(
                    "If you want to help feed the hungry and you can get around the gate go for it. ~Techoshi"
                )
            );

        if (_hash.length > 0) {
            require(
                true,
                "I'm just wasting your time. We did this offline. ~Techoshi"
            );
        }
        _;
    }

    constructor(
        address _vault,
        string memory __baseTokenURI,
        string memory _hiddenMetadataUri
    ) ERC721("ToothyTooths NFT", "SOS") {
        _MissingToothVault = _vault;
        _tokenSupply.increment();
        _safeMint(msg.sender, 0);
        _baseTokenURI = __baseTokenURI;
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    function withdraw() external onlyOwner {
        payable(_MissingToothVault).transfer(address(this).balance);
    }

    function afterHoursMissingToothMint(bytes32 mThree, uint256 amount)
        external
        payable
        isWhitelisted(msg.sender, mThree)
    {
        uint256 supply = _tokenSupply.current();

        require(
            supply + amount < maxAfterHoursMissingToothMints,
            "Not enough free mints remaining"
        );
        require(
            whitelistTokenPrice * amount <= msg.value,
            "Not enough ether sent"
        );
        require(amount <= whitelistmTL, "Mint amount too large");

        for (uint256 i = 0; i < amount; i++) {
            _tokenSupply.increment();
            _safeMint(msg.sender, supply + i);
        }
    }

    function openMissingToothMint(bytes32 mThree, uint256 quantity)
        external
        payable
        isWhitelisted(msg.sender, mThree)
    {
        uint256 supply = _tokenSupply.current();

        require(quantity <= mTL, "Mint amount too large");
        require(supply + quantity < MAX_TOKENS, "Not enough tokens remaining");
        require(tokenPrice * quantity <= msg.value, "Not enough ether sent");

        for (uint256 i = 0; i < quantity; i++) {
            _tokenSupply.increment();
            _safeMint(msg.sender, supply + i);
        }
    }

    function missingToothMint(address to, uint256 amount) external onlyOwner {
        uint256 supply = _tokenSupply.current();
        require(supply + amount < MAX_TOKENS, "Not enough tokens remaining");
        for (uint256 i = 0; i < amount; i++) {
            _tokenSupply.increment();
            _safeMint(to, supply + i);
        }
    }

    function setParams(
        uint256 newPrice,
        uint256 newWhitelistTokenPrice,
        uint256 setopenMissingToothMintLimit,
        uint256 setafterHoursMissingToothMintLimit,
        bool setPublicMintState,
        bool setPrivateMintState
    ) external onlyOwner {
        whitelistTokenPrice = newWhitelistTokenPrice;
        tokenPrice = newPrice;
        mTL = setopenMissingToothMintLimit;
        whitelistmTL = setafterHoursMissingToothMintLimit;
        publicMintIsOpen = setPublicMintState;
        privateMintIsOpen = setPrivateMintState;
    }

    function setTransactionMintLimit(uint256 newMintLimit) external onlyOwner {
        mTL = newMintLimit;
    }

    function setWhitelistTransactionMintLimit(uint256 newprivateMintLimit)
        external
        onlyOwner
    {
        whitelistmTL = newprivateMintLimit;
    }

    function setTokenPrice(uint256 newPrice) external onlyOwner {
        tokenPrice = newPrice;
    }

    function setFreeMints(uint256 amount) external onlyOwner {
        require(amount <= MAX_TOKENS, "Free mint amount too large");
        maxAfterHoursMissingToothMints = amount;
    }

    function toggleCooking() external onlyOwner {
        publicMintIsOpen = !publicMintIsOpen;
    }

    function togglePresaleCooking() external onlyOwner {
        privateMintIsOpen = !privateMintIsOpen;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenSupply.current();
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function setVaultAddress(address newVault) external onlyOwner {
        _MissingToothVault = newVault;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    receive() external payable {}

    function setBaseExtension(string memory _baseExtension) public onlyOwner {
        baseExtension = _baseExtension;
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setHiddenMetadataUri(string memory _hiddenMetadataUri)
        public
        onlyOwner
    {
        hiddenMetadataUri = _hiddenMetadataUri;
    }
}
