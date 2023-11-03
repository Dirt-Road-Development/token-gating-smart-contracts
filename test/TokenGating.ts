import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("TokenGating", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploymentFixture() {
    
    const [ owner ] = await ethers.getSigners();

    const factory = await ethers.getContractFactory("TokenGating");
    const contract = await factory.deploy();
    // await contract.waitForDeployed();

    const erc20Factory = await ethers.getContractFactory("TestToken");
    const erc20Contract = await erc20Factory.deploy();
    // await erc20Contract.waitForDeployed();

    return { owner, contract, erc20Contract };
  }

  describe("Test canAccess", function () {
    it("Should return false", async function () {
      const { contract, erc20Contract } = await loadFixture(deploymentFixture);

      const wallet = ethers.Wallet.createRandom();

      const response = await contract.canAccess(
        [
          [erc20Contract.target, 0, BigInt(0), BigInt(100)],
        ],
        wallet.address
      );
      expect(response[0]).to.be.false;
    });

    it("Should return True", async function () {
      const { contract, erc20Contract, owner } = await loadFixture(deploymentFixture);

      const wallet = ethers.Wallet.createRandom();

      await erc20Contract.mint(wallet.address);

      const response = await contract.canAccess(
        [
          [erc20Contract.target, 0, BigInt(0), BigInt(25)],
          [erc20Contract.target, 0, BigInt(0), BigInt(50)],
          [erc20Contract.target, 0, BigInt(0), BigInt(75)],
          [erc20Contract.target, 0, BigInt(0), (BigInt(150) * BigInt(10) ^ BigInt(18))]
        ],
        wallet.address
      );
      expect(response[0]).to.be.true;
    });
  });
});
