import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, artifacts } from "hardhat";

describe("Factory Contract", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.

  async function deployFactory() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy();
  
    await factory.deployed();
    const factoryAddress = factory.address;

    //-----------------------------------------------
    const salt = 1;
    const owner = "0x457160c55D80831cD903523f81114AE741710417";
    const walletname = "Simple Wallet2";

    const artifact = await artifacts.readArtifact("TestContract");
    const TestContractBytecode = artifact.bytecode;

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


    return { factoryAddress, salt, owner, walletname, bytecode};
  }

    describe("Verify Address", function () {
      it("verify that pre compute address is the same as the deployed address", async function () {
        const { factoryAddress, salt, owner, walletname, bytecode } = await loadFixture(deployFactory);
        const factoryContract = await ethers.getContractAt("Factory", factoryAddress);


        //get pre computed address of a contract
        const precomputedAddress = await factoryContract.preComputeAddress(salt, bytecode);

        //deploy the contract
        const createContract = await factoryContract.createContract(owner, walletname, salt);
        const txreceipt =  await createContract.wait()
        //@ts-ignore
        const txargs = txreceipt.events[0].args;
        //@ts-ignore
        const TestContractAddress = await txargs.deployedAddress

         expect(await TestContractAddress).to.equal(precomputedAddress);
    });

    it("verify the walletName and the owner address", async function () {
      const { factoryAddress, salt, owner, walletname, bytecode } = await loadFixture(deployFactory);
      const factoryContract = await ethers.getContractAt("Factory", factoryAddress);

      //get pre computed address of a contract
      const precomputedAddress = await factoryContract.preComputeAddress(salt, bytecode);

      //deploy the contract
      const createContract = await factoryContract.createContract(owner, walletname, salt);
      const txreceipt =  await createContract.wait()
      //@ts-ignore
      const txargs = txreceipt.events[0].args;
      //@ts-ignore
      const TestContractAddress = await txargs.deployedAddress

       //````````````````````````````````````````````````````````
       const TestContract = await ethers.getContractAt("TestContract", TestContractAddress);
       const walletName = await TestContract.walletName();
       const admin = await TestContract.admin();

       expect( walletName).to.equal(walletname);
       expect( admin).to.equal(owner);
  });
  });
});
