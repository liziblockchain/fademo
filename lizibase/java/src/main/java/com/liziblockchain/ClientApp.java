package com.liziblockchain;

import java.nio.file.Path;
import java.nio.file.Paths;

import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Network;
import org.hyperledger.fabric.gateway.Wallet;

public class ClientApp {

	static {
		System.setProperty("org.hyperledger.fabric.sdk.service_discovery.as_localhost", "true");
	}

	public static void main(String[] args) throws Exception {
		// Load a file system based wallet for managing identities.
		Path walletPath = Paths.get("wallet");
		Wallet wallet = Wallet.createFileSystemWallet(walletPath);

		// load a CCP
		Path networkConfigPath = Paths.get("..", "netconfig-org1.yaml");

		Gateway.Builder builder = Gateway.createBuilder();
		builder.identity(wallet, "user1").networkConfig(networkConfigPath).discovery(true);

		// create a gateway connection
		try (Gateway gateway = builder.connect()) {

			// get the network and contract
			Network network = gateway.getNetwork("liziblockchainchannel");
			Contract contract = network.getContract("mycc");

			byte[] result;

			result = contract.evaluateTransaction("query", "a");
			System.out.println("liziblockchain:------- result of query a: " + new String(result));

			System.out.println("liziblockchain:------- submit Tx of transfer a to b");
			contract.submitTransaction("invoke", "a", "b", "1");

			result = contract.evaluateTransaction("query", "a");
			System.out.println("liziblockchain:------- result of query a: " + new String(result));
		}
	}

}
