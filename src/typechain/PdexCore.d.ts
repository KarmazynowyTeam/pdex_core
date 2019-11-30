/* Generated by ts-generator ver. 0.0.8 */
/* tslint:disable */

import { Contract, ContractTransaction, EventFilter, Signer } from "ethers";
import { Listener, Provider } from "ethers/providers";
import { Arrayish, BigNumber, BigNumberish, Interface } from "ethers/utils";
import {
  TransactionOverrides,
  TypedEventDescription,
  TypedFunctionDescription
} from ".";

interface PdexCoreInterface extends Interface {
  functions: {
    approveBroker: TypedFunctionDescription<{
      encode([_brokerAddress]: [string]): string;
    }>;

    registerInvestor: TypedFunctionDescription<{
      encode([_investorAddress, _maxRiskRatio]: [string, BigNumberish]): string;
    }>;

    registerCompany: TypedFunctionDescription<{
      encode([_companyAddress]: [string]): string;
    }>;
  };

  events: {
    BrokerApproved: TypedEventDescription<{
      encodeTopics([brokerAddress]: [null]): string[];
    }>;

    CompanyRegistered: TypedEventDescription<{
      encodeTopics([byBroker, companyAddress]: [string | null, null]): string[];
    }>;

    InvestorRegistered: TypedEventDescription<{
      encodeTopics([byBroker, investorAddress, maxRiskRatio]: [
        string | null,
        null,
        null
      ]): string[];
    }>;
  };
}

export class PdexCore extends Contract {
  connect(signerOrProvider: Signer | Provider | string): PdexCore;
  attach(addressOrName: string): PdexCore;
  deployed(): Promise<PdexCore>;

  on(event: EventFilter | string, listener: Listener): PdexCore;
  once(event: EventFilter | string, listener: Listener): PdexCore;
  addListener(eventName: EventFilter | string, listener: Listener): PdexCore;
  removeAllListeners(eventName: EventFilter | string): PdexCore;
  removeListener(eventName: any, listener: Listener): PdexCore;

  interface: PdexCoreInterface;

  functions: {
    approveBroker(
      _brokerAddress: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    registerInvestor(
      _investorAddress: string,
      _maxRiskRatio: BigNumberish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    registerCompany(
      _companyAddress: string,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;
  };

  approveBroker(
    _brokerAddress: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  registerInvestor(
    _investorAddress: string,
    _maxRiskRatio: BigNumberish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  registerCompany(
    _companyAddress: string,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  filters: {
    BrokerApproved(brokerAddress: null): EventFilter;

    CompanyRegistered(
      byBroker: string | null,
      companyAddress: null
    ): EventFilter;

    InvestorRegistered(
      byBroker: string | null,
      investorAddress: null,
      maxRiskRatio: null
    ): EventFilter;
  };

  estimate: {
    approveBroker(_brokerAddress: string): Promise<BigNumber>;

    registerInvestor(
      _investorAddress: string,
      _maxRiskRatio: BigNumberish
    ): Promise<BigNumber>;

    registerCompany(_companyAddress: string): Promise<BigNumber>;
  };
}