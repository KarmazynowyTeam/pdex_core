import {Wallet, providers} from 'ethers';
import Token from '../build/PdexStable.json';
import { deployContractAndWait } from './helpers/deploy';

const deployToken = (wallet: Wallet) => deployContractAndWait(wallet, Token, []);

const deployContracts = async (privateKey: string, jsonRpcUrl: string) => {
  const provider = new providers.JsonRpcProvider(jsonRpcUrl, {chainId: 0, name: ''});
  const wallet = new Wallet(privateKey, provider);
  await deployToken(wallet);
}

if(process.argv.length === 4) {
  deployContracts(process.argv[2], process.argv[3]);
} else {
  console.log('Invalid syntax!');
}
