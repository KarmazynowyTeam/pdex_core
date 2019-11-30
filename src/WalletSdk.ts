import { utils, Wallet } from 'ethers';
import UniversalLoginSDK from '@universal-login/sdk';
import { ETHER_NATIVE_TOKEN } from '@universal-login/commons';

export class WalletSdk {
  private wallet: Wallet;
  constructor(private sdk: UniversalLoginSDK) {
    this.wallet = new Wallet('0x5c8b9227cd5065c7e3f6b73826b8b42e198c4497f6688e3085d5ab3a6d520e74', sdk.provider);
  }
  
  async createAndDeploy(ensName: string) {
    await this.sdk.start();
    const futureWallet = await this.sdk.createFutureWallet();
    this.wallet.sendTransaction({to: futureWallet.contractAddress, value: utils.parseEther('0.02')})
    await futureWallet.waitForBalance();
    const deployment = await futureWallet.deploy(ensName, '1', ETHER_NATIVE_TOKEN.address);
    await deployment.waitToBeSuccess();
  }
}
