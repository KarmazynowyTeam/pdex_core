pragma solidity 0.5.10;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol'; 
import './PdexCore.sol';


contract PDexDex {
    IERC20 tokenInstance;
    PdexCore pDexCoreInstance;

    struct Offer {
        address companyShares;

        uint sharesAmount;
        uint sharePrice;

        address issuer;
    }

    constructor(address _tokenAddress, address _coreContractAddress) public {
        tokenInstance = IERC20(_tokenAddress);
        pDexCoreInstance = PdexCore(_coreContractAddress);
    }

    modifier doesCompanyExist(address _companyAddress) {
        (
            bool _approve,
            address _broker,
            uint _sharesSupply,
            uint _initialSharePrice,
            uint _shareRiskRatio,
            uint _raisedFunds,
            uint _payoutAmount
        ) = pDexCoreInstance.companiesProfiles(_companyAddress);
        require(_approve, "Only registred companies shares can be traded");
        _;
    }

    mapping(uint => Offer) bids;
    uint bidsCount;

    mapping(uint => Offer) asks;
    uint asksCount;


    function addAskOffer(
        address _companyShares,
        uint _sharesAmount,
        uint _sharePrice
    ) public
    doesCompanyExist(_companyShares)
    {   
        if(asksCount == 0) {
            asks[asksCount] = Offer(_companyShares, _sharesAmount, _sharePrice, msg.sender);
            asksCount++;
            return;
        }

        if(_sharePrice < asks[asksCount - 1].sharePrice) {
            asks[asksCount] = Offer(_companyShares, _sharesAmount, _sharePrice, msg.sender);
        }

        asks[asksCount] = asks[asksCount - 1];
        asks[asksCount - 1] = Offer(_companyShares, _sharesAmount, _sharePrice, msg.sender);
        asksCount++;
    }

    function addBidOffer(
        address _companyShares,
        uint _sharesAmount,
        uint _sharePrice
    ) public
    doesCompanyExist(_companyShares)
    {
        if(bidsCount == 0) {
            bids[bidsCount] = Offer(_companyShares, _sharesAmount, _sharePrice, msg.sender);
            bidsCount++;
            return;
        }

        if(_sharePrice > bids[bidsCount - 1].sharePrice) {
            bids[bidsCount] = Offer(_companyShares, _sharesAmount, _sharePrice, msg.sender);
        }

        bids[asksCount] = bids[bidsCount - 1];
        bids[bidsCount - 1] = Offer(_companyShares, _sharesAmount, _sharePrice, msg.sender);
        bidsCount++;
    }

    function doOffersMatch() public
    view returns(bool) {
        if(bids[bidsCount].sharePrice > asks[asksCount].sharePrice) {
            return true;
        }
        return false;
    }

    function matchOffers() public {
        require(doOffersMatch(), "Last offers do not match");

        // TODO execute the transaction, todo implement shares transfers on the other contract
    }
}