import { ethers, artifacts} from "hardhat";

async function main() {
  const Factory = await ethers.getContractFactory("Factory");
  const factory = await Factory.deploy();
  await factory.deployed();

  console.log(`Factory contract deployed to ${factory.address}`);

  //------------------Variable--------------//
  const salt = 1;
  const owner = "0x457160c55D80831cD903523f81114AE741710417";
  const walletname = "Simple Wallet2";
  
    //--------------Get bytecode-------------------
    const artifact = await artifacts.readArtifact("TestContract");
    const TestContractBytecode = artifact.bytecode;
    console.log("TestContract bytecode", TestContractBytecode )

    // Create an instance of ethers.utils.AbiCoder
    const abiCoder = new ethers.utils.AbiCoder();
    
    // We encode the constructor parameter for TestContract
    // Define the types and values to encode
      const types = ["address", "string"];
      const values = [owner, walletname];

    // Encode the ata
    const encodeParameter = abiCoder.encode(types, values);

    //we romove the Ox in front of the encoded parameter
    const TestContractParameter = encodeParameter.slice(2);

    const bytecode = TestContractBytecode + TestContractParameter;
    //console.log("new byte code", bytecode)

  //----------------------------------------------------------------------

  const factoryContract = await ethers.getContractAt("Factory", factory.address);

  //get pre computed address of a contract
  const getAddress = await factoryContract.getAddress(salt, bytecode);
  console.log("Pre Computed address", getAddress);

  //-------------------------------------------------------//

  //deploy the contract
  const createContract = await factoryContract.createContract(owner, walletname, salt);
  const txreceipt =  await createContract.wait()
  //@ts-ignore
  const txargs = txreceipt.events[0].args;
  //@ts-ignore
  const TestContractAddress = await txargs.deployedContract
  console.log("Deployed Address", TestContractAddress);

  //--------------Interacting with the deployed simple wallet contract-------------
  const TestContract = await ethers.getContractAt("TestContract", TestContractAddress);

  //Get the wallet Name
  const walletName = await TestContract.walletName();
  console.log("wallet name", walletName);

  //Get the admin address
  const admin = await TestContract.admin();
  console.log("admin", admin);


/**if you try to deploy the contract with the salt again, It revert because "Contract already created with the same salt"*/
//to deploy a replica of the contract, you need to change the salt value

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
