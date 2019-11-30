import {ContractFactory, Wallet, utils} from 'ethers';

export async function deployContract(wallet: Wallet, contractJSON: any, args = [], overrides: any) {
  const factory = new ContractFactory(contractJSON.abi, contractJSON.bytecode, wallet);
  return factory.deploy(...args, overrides);
};

export async function deployContractAndWait(wallet: Wallet, contractJSON: any, args = [], overrides?: any) {
  const deployTransaction = {
    gasLimit: utils.bigNumberify('3000000'),
    gasPrice: utils.bigNumberify('3000000'),
    ...overrides,
    ...new ContractFactory(contractJSON.abi, contractJSON.bytecode).getDeployTransaction(...args),
  };
  const {hash} = await wallet.sendTransaction(deployTransaction);
  console.log(`Transaction hash: ${hash}`);
  const {contractAddress} = await wallet.provider.waitForTransaction(hash!);
  console.log(`Contract will be deployed at: ${contractAddress}`)
  return contractAddress!;
};