import { PdexCore } from './typechain/PdexCore';
import { Wallet, Contract, providers } from 'ethers';
import ContractBuild from '../build/PdexCore.json';

export class PDexSdk {
  private wallet: Wallet;
  private contractInstance: PdexCore;
  constructor(privateKey: string, contractAddress: string, providerUrl: string) {
    this.wallet = new Wallet(privateKey, new providers.JsonRpcProvider(providerUrl));
    this.contractInstance = new Contract(contractAddress, ContractBuild.abi, this.wallet) as PdexCore;
  }
}
