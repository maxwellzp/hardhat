const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AppContract", function () {
  let owner;
  let app;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();

    const Logger = await ethers.getContractFactory("Logger", owner);
    const logger = await Logger.deploy();
    const address = await logger.getAddress();
    await logger.waitForDeployment();

    const AppContract = await ethers.getContractFactory("AppContract", owner);
    app = await AppContract.deploy(address);
    await app.waitForDeployment();
  });

  it("allows to pay and get payment info", async function () {
    const sum = 100;

    const txData = {
      value: sum,
      to: app.getAddress(),
    };

    const tx = await owner.sendTransaction(txData);

    await tx.wait();

    await expect(tx).to.changeEtherBalance(app, sum);

    const amount = await app.payment(owner.getAddress(), 0);
    expect(amount).to.eq(sum);
  });
});
