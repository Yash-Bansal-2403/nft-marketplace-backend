// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; //to use 
//1-getApproved function -> returns the address of the approved contracts who can buy/sell the NFT -> helps to check if marketplace is the approved seller of NFT
//2-ownerOf function -> to check if the address trying to list NFT is the actual owner of the NFT
//3-safeTransferFrom -> to transfer NFT from seller to buyer

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";//to use nonReentrant in buyItem function

//Functions performed by mrketplace-
//1. List an NFT
//2. Buy NFT->buying an NFT will automatically remove the NFT from active listings in marketplace and transfer the money(proceeds) to the seller account
//3. Update NFT listing-> update the price of NFT lisitng
//4. Cancel listing-> cancel the NFT from active listings
//5. WithdrawProceeds: the payment of the sold NFT is withdtrawn by the user through this

//-------------------------------Errors-----------------------------------------

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();
error IsNotOwner();

//-------------------------------Errors end-----------------------------------------

//inheriting ReentrancyGuard to prevent reentrancy attack ny adding nonRentrant modifier to the functions which are prone to attack(buyItem function)
contract NftMarketplace is ReentrancyGuard {
    //Data type for holding the data of listed NFT
    struct Listing {
        uint256 price;
        address seller;
    }
    //-------------------------Events----------------------------------------------

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);

    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    //-----------------------Events Closed-----------------------------------------------
    
    //-----------------------Mappings----------------------------------------------------

    mapping(address => mapping(uint256 => Listing)) private s_listings; //holding the NFTs in a mapping ( NFTAddress->NFTtokenId->NFT)
    mapping(address => uint256) private s_proceeds;//holding the proceeds(money after selling the NFT) of different users in a mapping( user's address -> proceed(money as uint256))    
    //----------------------Mappings closed----------------------------------------
   
    //----------------------Modifiers----------------------------------------------

    //@ modofier to make sure not to list already listed NFT
    modifier notListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        //if the price is greater than 0 it means that NFT is already listed on marketplace
        if (listing.price > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    } 

    //@ modifier to make sure NFT is listed before someone try to buy NFT
    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert NotListed(nftAddress, tokenId);
        }
        _;
    }

    //@ modifier to make sure that the person listing the NFT is the actual owner of that NFT
    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender//address trying to list NFT
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    // IsNotOwner Modifier - Nft Owner can't buy his/her NFT
    // Modifies buyItem function
    // Owner should only list, cancel listing or update listing
     modifier isNotOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender == owner) {
            revert IsNotOwner();
        }
        _;
    } 

    //----------------------------------Modifiers close-------------------------------------

    // --------------------------Main Functions -------------------------------//

    /*
     * @notice Method for listing NFT
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @param price sale price for each item
     * @modifier notListed for preventing listing of already listed NFTs
     * @modifier isOwner to make sure that the person listing the NFT is the actual owner of that NFT
     */
    function listItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external notListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) {
        if (price <= 0) {
            revert PriceMustBeAboveZero(); //revert if lisiting price is <= 0
        }
        //now we provide approval to the marketplace to sell the NFT on behalf of the seller of NFT
        IERC721 nft = IERC721(nftAddress); //we use ERC721 interface to use getApproved functionality
        if (nft.getApproved(tokenId) != address(this)) {
            // getApproved function is provided by the ERC721 from openZeppelin
            //nft.getApproved(tokenId) returns the address of the approved contracts who can buy/sell the NFT
            revert NotApprovedForMarketplace();
        }
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender); //listing NFT in the marketplace
        emit ItemListed(msg.sender, nftAddress, tokenId, price); //whenever we update mapping we emit event
    }

    /*
     * @notice Method for cancelling listing
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @modifier isOwner to check only the owner can cancel Listing
     * @modifier isListed to check first whether the NFT is listed or not before cancelling the listing
     */
    function cancelListing(
        address nftAddress,
        uint256 tokenId
    ) external isOwner(nftAddress, tokenId, msg.sender) isListed(nftAddress, tokenId) {
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    /*
     * @notice Method for buying listing
     * @notice The owner of an NFT could unapprove the marketplace,
     * which would cause this function to fail
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @ modifier isListed to make sure NFT is listed before someone try to buy NFT
     * @ modifier isNotOwner to check if buyer is not already an owner
     */
    function buyItem(
        address nftAddress,
        uint256 tokenId
    )
        external
        payable
        isListed(nftAddress, tokenId)
        isNotOwner(nftAddress, tokenId, msg.sender)
        nonReentrant
    {

        Listing memory listedItem = s_listings[nftAddress][tokenId];//extract the NFT from mapping to be bought

        //to check if the money sent is sufficient to buy an NFT
        if (msg.value < listedItem.price) {
            revert PriceNotMet(nftAddress, tokenId, listedItem.price);
        }
        s_proceeds[listedItem.seller] += msg.value;//updating the money which user hold
        delete (s_listings[nftAddress][tokenId]);//deleting the active listing after the NFT is bought

        //we use "PULL OVER PUSH" functionality i.e transferrring the risk of money transaction to the end user,
        //instead of sending money to the user, we make to have user withdraw the money
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);//transfering the NFT at the last step to prevent reentrancy attack
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    /*
     * @notice Method for updating listing
     * @param nftAddress Address of NFT contract
     * @param tokenId Token ID of NFT
     * @param newPrice Price in Wei of the item
     * @ modifier isListed to make sure NFT is listed before someone try to update NFT listing
     * @ modifier isOwner to check if only owner can update the listing
     */
    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    ) external isListed(nftAddress, tokenId) nonReentrant isOwner(nftAddress, tokenId, msg.sender) {
        //We should check the value of `newPrice` and revert if it's below zero (like we also check in `listItem()`)
        if (newPrice <= 0) {
            revert PriceMustBeAboveZero();
        }
        s_listings[nftAddress][tokenId].price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    /*
     * @notice Method for withdrawing proceeds from sales
     */
    function withdrawProceeds() external {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    
    // ------------------------------Getter Functions------------------------------------------------- //
    

    function getListing(
        address nftAddress,
        uint256 tokenId
    ) external view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }

    function getProceeds(address seller) external view returns (uint256) {
        return s_proceeds[seller];
    }
}
