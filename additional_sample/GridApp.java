package org.example;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.security.PrivateKey;
import java.util.Properties;
import java.util.Set;
import java.util.Collection;

// import org.hyperledger.fabric.gateway.Contract;
// import org.hyperledger.fabric.gateway.Gateway;
// import org.hyperledger.fabric.gateway.Network;
// import org.hyperledger.fabric.gateway.Wallet;
// import org.hyperledger.fabric.gateway.Wallet.Identity;

// import org.hyperledger.fabric.sdk.Enrollment;
// import org.hyperledger.fabric.sdk.User;
// import org.hyperledger.fabric.sdk.security.CryptoSuite;
// import org.hyperledger.fabric.sdk.security.CryptoSuiteFactory;
import org.hyperledger.fabric.sdk.*;

import org.hyperledger.fabric_ca.sdk.*;
// import org.hyperledger.fabric_ca.sdk.HFCAClient;
// import org.hyperledger.fabric_ca.sdk.RegistrationRequest;
// import org.hyperledger.fabric_ca.sdk.EnrollmentRequest;

// import org.hyperledger.fabric.sdk.User;
import org.hyperledger.fabric.sdk.security.*;//CryptoPrimitives;
import org.hyperledger.fabric.sdk.identity.X509Enrollment;
 

public class GridApp {

	static {
		System.setProperty("org.hyperledger.fabric.sdk.service_discovery.as_localhost", "true");
	}

	static User admin;
	static User user1;

	static final String prjHome = "/work/fabric/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/";

	public static void main(String[] args) throws Exception {
		admin = getAdminUser();
		user1 = getUser1(admin);

		query(user1);
		// test2();
		// System.out.println("-----zrk------ counter app");
	}



	public static void test2() throws Exception{
		//创建User实例
		String strtmp = prjHome + "users/User1@org1.example.com/msp/";
		// String keyFile = "../solo-network/msp/keystore/user-key.pem";
		// String certFile = "../solo-network/msp/signcerts/user-cert.pem";
		String keyFile = strtmp + "keystore/d095f06b855f5f4900ac0652655c2b53b2717c2e49c5fb5f360f3a049473f56e_sk";
		String certFile = strtmp + "signcerts/User1@org1.example.com-cert.pem";

		System.out.println("----zrk----" + keyFile);
		System.out.println("----zrk----" + certFile);

		// LocalUser user = new LocalUser("admin","SampleOrg",keyFile,certFile);
		LocalUser user = new LocalUser("user1", "Org1MSP");
		user.loadpem(keyFile,certFile);

		//创建HFClient实例
		HFClient client = HFClient.createNewInstance();
		client.setCryptoSuite(CryptoSuite.Factory.getCryptoSuite());
		client.setUserContext(user);

		//创建通道实例
		Channel channel = client.newChannel("mychannel");
		Peer peer = client.newPeer("peer0.org1.example.com","grpcs://localhost:7051");
		channel.addPeer(peer);
		// Orderer orderer = client.newOrderer("orderer.example.com","grpc://127.0.0.1:7050");
		// channel.addOrderer(orderer);
		channel.initialize();

		//查询链码
		QueryByChaincodeRequest req = client.newQueryProposalRequest();
		ChaincodeID cid = ChaincodeID.newBuilder().setName("fabcar").build();
		req.setChaincodeID(cid);
		req.setFcn("value");
		ProposalResponse[] rsp = channel.queryByChaincode(req).toArray(new ProposalResponse[0]);
		System.out.format("rsp message => %s\n",rsp[0].getProposalResponse().getResponse().getPayload().toStringUtf8());
	 
		//提交链码交易
		// TransactionProposalRequest req2 = client.newTransactionProposalRequest();
		// req2.setChaincodeID(cid);
		// req2.setFcn("inc");
		// req2.setArgs("10");
		// Collection<ProposalResponse> rsp2 = channel.sendTransactionProposal(req2);
		// TransactionEvent event = channel.sendTransaction(rsp2).get();
		// System.out.format("txid: %s\n", event.getTransactionID());
		// System.out.format("valid: %b\n", event.isValid());
	  }

    public static User getAdminUser() throws Exception
    {
		String strCApem = prjHome + "ca/ca.org1.example.com-cert.pem";

		String caUrl = "https://localhost:7054"; // ensure that port is of CA
		// String caName = "ca_peerOrg1";
		// String pemStr = "-----BEGIN CERTIFICATE-----\r\n****\r\n-----END CERTIFICATE-----\r\n";
		
		// byte[] pemBytes = Files.readAllBytes(Paths.get(strCApem));   //载入证书PEM文本


		Properties properties = new Properties();
		// properties.put("pemBytes", pemBytes);
		
		properties.put("pemFile", strCApem);
		properties.put("allowAllHostNames", "true");

		// HFCAClient hfcaClient = HFCAClient.createNewInstance(caName, caUrl, properties);
		HFCAClient hfcaClient = HFCAClient.createNewInstance(caUrl, properties);

		CryptoSuite cryptoSuite = CryptoSuite.Factory.getCryptoSuite();
		hfcaClient.setCryptoSuite(cryptoSuite);

		LocalUser adminUserContext = new LocalUser(null,null);
		adminUserContext.setName("admin"); // admin username
		// adminUserContext.setAffiliation("org1"); // affiliation
		adminUserContext.setMspId("Org1MSP"); // org1 mspid

		System.out.println("-----zrk------ 11111");
		Enrollment adminEnrollment = hfcaClient.enroll("admin", "adminpw"); //pass admin username and password
		System.out.println("-----zrk------ 22222 cert\n" + adminEnrollment.getCert());
		System.out.println("-----zrk------ 22222 key\n" + adminEnrollment.getKey());
		adminUserContext.setEnrollment(adminEnrollment);
		System.out.println("-----zrk------ 33333");

		return adminUserContext;
		// Util.writeUserContext(adminUserContext); // save admin context to local file system

	  }


	  public static User getUser1(User admin) throws Exception
	  {
		  String strCApem = prjHome + "ca/ca.org1.example.com-cert.pem";
  
		  String caUrl = "https://localhost:7054"; // ensure that port is of CA
		  // String caName = "ca_peerOrg1";
		  // String pemStr = "-----BEGIN CERTIFICATE-----\r\n****\r\n-----END CERTIFICATE-----\r\n";
		  
		  // byte[] pemBytes = Files.readAllBytes(Paths.get(strCApem));   //载入证书PEM文本
  
  
		  Properties properties = new Properties();
		  properties.put("pemFile", strCApem);
		  properties.put("allowAllHostNames", "true");
  
		  // HFCAClient hfcaClient = HFCAClient.createNewInstance(caName, caUrl, properties);
		  CryptoSuite cryptoSuite = CryptoSuite.Factory.getCryptoSuite();
		  HFCAClient hfcaClient = HFCAClient.createNewInstance(caUrl, properties);
		  hfcaClient.setCryptoSuite(cryptoSuite);
  
		  LocalUser user = new LocalUser(null,null);
		  user.setName("user1"); // admin username
		  // adminUserContext.setAffiliation("org1"); // affiliation
		  user.setMspId("Org1MSP"); // org1 mspid
		  user.setAffiliation("org1.department1");

		  Enrollment enrollment = null;
		  try
		  {
			RegistrationRequest rr = new RegistrationRequest("user1", "org1.department1");
			rr.setEnrollmentID("user1");
			String enrollmentSecret = hfcaClient.register(rr, admin);
			enrollment = hfcaClient.enroll(user.getName(), enrollmentSecret);
  
			//   String enrollmentSecret = caClient.register(registrationRequest, admin);
			//   enrollment = caClient.enroll("user1", enrollmentSecret);
		  } catch (Exception ex)
		  {
			enrollment = hfcaClient.reenroll(admin);
			//   enrollment = caClient.reenroll(admin);
		  }
  
		//   RegistrationRequest rr = new RegistrationRequest("user1", "org1.department1");
		//   rr.setEnrollmentID("user1");
		//   String enrollmentSecret = hfcaClient.register(rr, admin);

		//   Enrollment enrollment = hfcaClient.enroll(user.getName(), enrollmentSecret);

		  user.setEnrollment(enrollment);
		// Util.writeUserContext(userContext);


		//   user.setEnrollment();
		//   System.out.println("-----zrk------ 11111");
		//   Enrollment adminEnrollment = hfcaClient.enroll("admin", "adminpw"); //pass admin username and password
		  System.out.println("-----zrk------ 333333 cert\n" + enrollment.getCert());
		  System.out.println("-----zrk------ 33333 key\n" + enrollment.getKey());
		//   adminUserContext.setEnrollment(adminEnrollment);
		//   System.out.println("-----zrk------ 33333");
  
		  return user;
		  // Util.writeUserContext(adminUserContext); // save admin context to local file system
  
		}



		public static void query(User user)  throws Exception
		{
			CryptoSuite cryptoSuite = CryptoSuite.Factory.getCryptoSuite();
			HFClient hfClient = HFClient.createNewInstance();
			hfClient.setCryptoSuite(cryptoSuite);
			hfClient.setUserContext(admin);


			// String peer_name = "peer0.org1.example.com";
			String peer_name = "peer0";
			String peer_url = "grpcs://localhost:7051"; // Ensure that port is of peer1
			// String pemStr = "-----BEGIN CERTIFICATE-----\r\nxxxxxx\r\n";

			// String pemfile = prjHome + "ca/ca.org1.example.com-cert.pem";
			String pemfile = prjHome + "tlsca/tlsca.org1.example.com-cert.pem";
			// String pemfile = prjHome + "peers/peer0.org1.example.com/tls/ca.crt";

			Properties peer_properties = new Properties();
			// peer_properties.put("pemBytes", pemStr.getBytes());
			byte[] keyPem = Files.readAllBytes(Paths.get(pemfile));     //载入私钥PEM文本
			peer_properties.put("pemBytes", keyPem);
			// peer_properties.put("pemFile", pemfile);
			// peer_properties.put("allowAllHostNames", "true");
 		    peer_properties.setProperty("sslProvider", "openSSL");
			peer_properties.setProperty("negotiationType", "TLS");
			System.out.println("-----zrk------- cafile:\n" + new String(keyPem));

		   
			Peer peer = hfClient.newPeer(peer_name, peer_url, peer_properties);
		   
			// String event_url = "grpcs://xxxxxx-org1-peer1.xxxx.blockchain.ibm.com:31003"; // ensure that port is of event hub
			// EventHub eventHub = hfClient.newEventHub(peer_name, event_url, peer_properties);
		   
			// String orderer_name = "orderer";
			// String orderer_url = "grpcs://localhost:7050"; // ensure that port is of orderer
			// // String pemStr1 = "-----BEGIN CERTIFICATE-----\r\nxxxxx\r\n-----END CERTIFICATE-----\r\n";
			// String pemFile2 = "/work/fabric/fabric-samples/first-network/crypto-config/ordererOrganizations/example.com/ca/ca.example.com-cert.pem";
		   
			// Properties orderer_properties = new Properties();
			// // orderer_properties.put("pemBytes", pemStr1.getBytes());
			// orderer_properties.put("pemFile", pemFile2);
			// orderer_properties.put("allowAllHostNames", "true");
			// orderer_properties.setProperty("sslProvider", "openSSL");
			// orderer_properties.setProperty("negotiationType", "TLS");
			// Orderer orderer = hfClient.newOrderer(orderer_name, orderer_url, orderer_properties);

			Channel channel = hfClient.newChannel("mychannel");
			channel.addPeer(peer);
			// channel.addEventHub(eventHub);
			// channel.addOrderer(orderer);
			channel.initialize();



			String cc = "fabcar"; // Chaincode name
			ChaincodeID ccid = ChaincodeID.newBuilder().setName(cc).build();
			QueryByChaincodeRequest queryRequest = hfClient.newQueryProposalRequest();
			queryRequest.setChaincodeID(ccid); // ChaincodeId object as created in Invoke block
			queryRequest.setFcn("queryAllCars"); // Chaincode function name for querying the blocks

			String[] arguments = { "all"}; // Arguments that the above functions take
			if (arguments != null)
			queryRequest.setArgs(arguments);

			// Query the chaincode  
			System.out.println("-----zrk------- 11111111, before query");
			Collection<ProposalResponse> queryResponse = channel.queryByChaincode(queryRequest);
			System.out.println("-----zrk------- 2222222222, after query");

			for (ProposalResponse pres : queryResponse) {
			// process the response here
			}

			// TransactionProposalRequest request = hfClient.newTransactionProposalRequest();
			// String cc = "fabcar"; // Chaincode name
			// ChaincodeID ccid = ChaincodeID.newBuilder().setName(cc).build();
		   
			// request.setChaincodeID(ccid);
			// request.setFcn("queryAllCars"); // Chaincode invoke funtion name
			// String[] arguments = { "N4", "Provider", "28-01-2019", "Food", "1000", "04-02-2019" }; // Arguments that Chaincode function takes
			// request.setArgs(arguments);
			// request.setProposalWaitTime(3000);
			// System.out.println("-----zrk------- 11111111");
			// Collection<ProposalResponse> responses = channel.sendTransactionProposal(request);
			// System.out.println("-----zrk------- 22222222");
			// for (ProposalResponse res : responses) {
			//   // Process response from transaction proposal
			// }
		}
}



class LocalUser implements User {             //实现User接口
  private String name;
  private String mspId;
  private String  affiliation;
  private Enrollment enrollment;

  public void setEnrollment(Enrollment n)
  {
	  this.enrollment = n;
  }

  public void setName(String n)
  {
	  this.name = n;
  }

  public void setAffiliation(String n)
  {
	  this.affiliation = n;
  }


  public void setMspId(String n)
  {
	  this.mspId = n;
  }


  LocalUser(String name,String mspId) {
    this.name = name;
	this.mspId = mspId;
  }

  public void loadpem(String keyFile, String certFile) throws Exception {
	this.enrollment = loadFromPemFile(keyFile, certFile);
  }
 
  private Enrollment loadFromPemFile(String keyFile,String certFile) throws Exception {
	byte[] keyPem = Files.readAllBytes(Paths.get(keyFile));     //载入私钥PEM文本
	byte[] certPem = Files.readAllBytes(Paths.get(certFile));   //载入证书PEM文本

	System.out.println("----zrk----111111\n" + new String(keyPem));
	System.out.println("----zrk----222222\n" + new String(certPem));

	CryptoPrimitives suite = new CryptoPrimitives();            //载入密码学套件
	PrivateKey privateKey = suite.bytesToPrivateKey(keyPem);    //将PEM文本转换为私钥对象
	return new X509Enrollment(privateKey,new String(certPem));  //创建并返回X509Enrollment对象
  }
 
  @Override public String getName(){ return name; }
  @Override public String getMspId() { return mspId; }
  @Override public Enrollment getEnrollment() { return enrollment; }
  @Override public String getAccount() { return null; }
  @Override public String getAffiliation() { return affiliation; }
  @Override public Set<String>	getRoles(){ return null; }
}
// 在Fabric Java SDK中，Enrollment接口用来提供对用户的私钥和证书的访问，并且预置了一个适合X509证书的实现类X509Enrollment，因此我们可以从本地MSP目录中的PEM文件中载入用户私钥和签名证书：

// private Enrollment loadFromPemFile(String keyFile,String certFile) throws Exception{
//   byte[] keyPem = Files.readAllBytes(Paths.get(keyFile));     //载入私钥PEM文本
//   byte[] certPem = Files.readAllBytes(Paths.get(certFile));   //载入证书PEM文本
//   CryptoPrimitives suite = new CryptoPrimitives();            //载入密码学套件
//   PrivateKey privateKey = suite.bytesToPrivateKey(keyPem);    //将PEM文本转换为私钥对象
//   return new X509Enrollment(privateKey,new String(certPem));  //创建并返回X509Enrollment对象
// }
