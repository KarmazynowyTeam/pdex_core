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
        require(pDexCoreInstance.companiesProfiles[_companyAddress].approved, "Only registred companies shares can be traded");
        _;
    }

    Offer[] bids;
    Offer[] asks;

    function addAskOffer(
        address _companyShares,
        uint _sharesAmount,
        uint _sharePrice
    ) public
    doesCompanyExist(_companyShares)
    {
        asks.push(new Offer(_companyShares, _sharesAmount, _sharePrice, msg.sender));
    }

    function addBidOffer(
        address _companyShares,
        uint _sharesAmount,
        uint _sharePrice
    ) public
    doesCompanyExist(_companyShares)
    {
        bids.push(new Offer(_companyShares, _sharesAmount, _sharePrice, msg.sender));
    }
}