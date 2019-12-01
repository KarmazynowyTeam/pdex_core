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
    event CompanyRegistered(address indexed byBroker, address companyAddress, uint sharesSupply, uint sharePrice);
    event InvestorRegistered(address indexed byBroker, address investorAddress, uint maxRiskRatio);
    event PayoutClaimed(address indexed byCompany, uint amount);
    event ProfitPayout(address indexed fromCompany, uint amount, address indexed by);
    event ShareTransfer(address indexed companyShares, uint amount, address indexed from, address indexed to);
    event Allowance(address indexed companyShares, uint amount, address allower, address allowed);

    address owner;
    address knf;

    IERC20 tokenInstance;

    mapping(address => InvestorProfile) investorsProfiles;
    mapping(address => bool) brokers;
    mapping(address => CompanyProfile) public companiesProfiles;

    mapping(address => mapping(address => uint)) public shares;
    mapping(address => mapping(address => mapping(address => uint))) public allowances;

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

    modifier investorRegistered(address _investorAddress) {
        require(investorsProfiles[_investorAddress].approved, "User with the given address does not exists");
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
        require(_initialSharePrice.mul(_sharesAmount) < 4000000, "The capitalization to be raised cannot be above 4000000");
        companiesProfiles[_companyAddress].approved = true;
        companiesProfiles[_companyAddress].fromBroker = msg.sender;

        companiesProfiles[_companyAddress].sharesSupply = _sharesAmount;
        companiesProfiles[_companyAddress].initialSharePrice = _initialSharePrice;
        companiesProfiles[_companyAddress].shareRiskRatio = _riskRatio;

        shares[_companyAddress][_companyAddress] = _sharesAmount;

        emit CompanyRegistered(msg.sender, _companyAddress, _sharesAmount, _initialSharePrice);
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

    function transferShare(
        address _companyAddress,
        uint _amount,
        address _recipient,
        address _sender
    ) public investorRegistered(_recipient) investorRegistered(_sender) isCompany(_companyAddress) {
        require(allowances[msg.sender][_companyAddress][_sender] >= _amount || _sender == msg.sender, "You're not allowed to spend such an amount of tokens");
        require(shares[_companyAddress][_sender] > _amount, "Unsufficient shares");
        shares[_companyAddress][_sender] -= _amount;
        shares[_companyAddress][_recipient] += _amount;
        emit ShareTransfer(_companyAddress, _amount, _sender, _recipient);
    }

    function allowShareSpending(address _companyAddress, uint _amount, address _allowed) public {
        require(shares[_companyAddress][msg.sender] > _amount, "Unsufficient shares");
        allowances[_allowed][_companyAddress][msg.sender] = _amount;
        emit Allowance(_companyAddress, _amount, msg.sender, _allowed);
    }

    // Getters

    function getAllowance(address _allowed, address _companyAddress, address _sharesOwner) public view returns(uint) {
        return allowances[_allowed][_companyAddress][_sharesOwner];
    }
}

