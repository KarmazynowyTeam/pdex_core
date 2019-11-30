pragma solidity 0.5.10;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';


contract PdexCore {

    // Structs

    struct InvestorProfile {
        bool approved;
        uint maxRiskRatio;
        address fromBroker;
    }

    struct CompanyProfile {
        uint sharesSupply;
        uint initialSharePrice;
    }

    address owner;
    address krs;

    IERC20 tokenInstance;

    mapping(address => InvestorProfile) investorsProfiles;
    mapping(address => bool) brokers;
    mapping(address => CompanyProfile) companiesProfiles;

    constructor(address _tokenAddress, address _krsAddress) public {
        owner = msg.sender;

        krs = _krsAddress;
        tokenInstance = IERC20(_tokenAddress);
    }



}

