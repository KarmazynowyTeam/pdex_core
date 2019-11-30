pragma solidity 0.5.10;

import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';


contract PdexCore {

    using SafeMath for uint;

    // Structs

    struct InvestorProfile {
        bool approved;
        uint maxRiskRatio;
        address fromBroker;
    }

    struct CompanyProfile {
        bool approved;
        address fromBroker;
        uint sharesSupply;
        uint initialSharePrice;

        uint shareRiskRatio;

        uint raisedFunds;

        uint payoutAmount;
    }

    // Events

    event BrokerApproved(address brokerAddress);
    event CompanyRegistered(address indexed byBroker, address companyAddress);
    event InvestorRegistered(address indexed byBroker, address investorAddress, uint maxRiskRatio);
    event PayoutClaimed(address indexed byCompany, uint amount);
    event ProfitPayout(address indexed fromCompany, uint amount, address indexed by);

    address owner;
    address knf;

    IERC20 tokenInstance;

    mapping(address => InvestorProfile) investorsProfiles;
    mapping(address => bool) brokers;
    mapping(address => CompanyProfile) companiesProfiles;

    mapping(address => mapping(address => uint)) shares;

    constructor(address _tokenAddress, address _knfAddress) public {
        owner = msg.sender;

        knf = _knfAddress;
        tokenInstance = IERC20(_tokenAddress);
    }

    // modifiers

    modifier isKnf() {
        require(msg.sender == knf, "KNF restricted");
        _;
    }

    modifier isBroker() {
        require(brokers[msg.sender], "KNF approvement required");
        _;
    }

    modifier companyDoesNotExist(address _companyAddress) {
        require(!companiesProfiles[_companyAddress].approved, 'Company with the given address is already registered');
        _;
    }

    modifier investorIsNotRegistered(address _investorAddress) {
        require(!investorsProfiles[_investorAddress].approved, "User with the given address already exists");
        _;
    }

    modifier isCompany(address _company) {
        require(companiesProfiles[_company].approved, "Only companies are allowed to call this method");
        _;
    }

    // State changing functions

    // KRS restricted methods

    function approveBroker(address _brokerAddress) public isKnf() {
        brokers[_brokerAddress] = true;
        emit BrokerApproved(_brokerAddress);
    }

    // Broker rertricted methods

    function registerCompany(
        address _companyAddress,
        uint _sharesAmount,
        uint _initialSharePrice,
        uint _riskRatio
    ) public
    isBroker()
    companyDoesNotExist(_companyAddress)
    {
        companiesProfiles[_companyAddress].approved = true;
        companiesProfiles[_companyAddress].fromBroker = msg.sender;

        companiesProfiles[_companyAddress].sharesSupply = _sharesAmount;
        companiesProfiles[_companyAddress].initialSharePrice = _initialSharePrice;
        companiesProfiles[_companyAddress].shareRiskRatio = _riskRatio;

        emit CompanyRegistered(msg.sender, _companyAddress);
    }

    function registerInvestor(address _investorAddress, uint _maxRiskRatio) public
    isBroker()
    investorIsNotRegistered(_investorAddress)
    {
        investorsProfiles[_investorAddress].approved = true;
        investorsProfiles[_investorAddress].maxRiskRatio = _maxRiskRatio;
        investorsProfiles[_investorAddress].fromBroker = msg.sender;
        emit InvestorRegistered(msg.sender, _investorAddress, _maxRiskRatio);
    }

    // Company restricted methods

    function claimPayout(uint _amount) public
    isCompany(msg.sender)
    {
        require(tokenInstance.balanceOf(msg.sender) >= _amount && tokenInstance.allowance(msg.sender, address(this)) >= _amount);
        tokenInstance.transferFrom(msg.sender, address(this), _amount);
        companiesProfiles[msg.sender].payoutAmount = _amount;
        emit PayoutClaimed(msg.sender, _amount);
    }

    // Investor restricted methods

    function stakeProfit(address _companyAddress) public
    isCompany(msg.sender)
    {
        uint _payout =  shares[_companyAddress][msg.sender].div(companiesProfiles[_companyAddress].sharesSupply).mul(companiesProfiles[_companyAddress].payoutAmount);
        tokenInstance.transferFrom(address(this), msg.sender, _payout);
        emit ProfitPayout(_companyAddress, _payout, msg.sender);
    }
}

