import { PdexCore } from '../typechain-build/PdexCore';
import { constants, Contract, providers, utils } from 'ethers';
import ContractBuild from '../build/PdexCore.json';
import UniversalLoginSdk from '@universal-login/sdk';

export class PDexSdk {
  private provider: providers.JsonRpcProvider;
  private coreInstance: PdexCore;
  constructor(
    private privateKey: string,
    private userAddress: string,
    private coreAddress: string,
    providerUrl: string,
    private sdk: UniversalLoginSdk,
  ) {
    this.provider = new providers.JsonRpcProvider(providerUrl);
    this.coreInstance = new Contract(coreAddress, ContractBuild.abi, this.provider) as PdexCore;
  }

  async approveBroker(brokerAddress: string) {
    return this.executeCoreFunction('approveBroker', [brokerAddress]);
  }

  async registerCompany(companyAddress: string, sharesAmount: string, initialSharePrice: string, riskRatio: string) {
    return this.executeCoreFunction('registerCompany', [companyAddress, sharesAmount, initialSharePrice, riskRatio]);
  }

  async registerInvestor(investorAddress: string, maxRiskRatio: string) {
    return this.executeCoreFunction('registerInvestor', [investorAddress, maxRiskRatio]);
  }

  async claimPayout(amount: string) {
    return this.executeCoreFunction('claimPayout', [amount]);
  }

  async stakeProfit(companyAddress: string) {
    return this.executeCoreFunction('stakeProfit', [companyAddress]);
  }

  async allowShareSpending(companyAddress: string, amount: string, allowed: string) {
    return this.executeCoreFunction('allowShareSpending', [companyAddress, amount, allowed]);
  }

  async executeCoreFunction(functionName: string, args: string[]) {
    const data = this.coreInstance.interface.functions[functionName].encode(args);
    const { waitToBeSuccess } = await this.sdk.execute(this.getMessage(data, this.coreAddress), this.privateKey);
    await waitToBeSuccess();
  }

  getMessage(data: string, target: string) {
    return {
      to: target,
      from: this.userAddress,
      data,
      gasPrice: utils.bigNumberify(9000000000),
      gasLimit: utils.bigNumberify(220000),
      gasToken: constants.AddressZero,
      value: 0,
    };
  }
}
