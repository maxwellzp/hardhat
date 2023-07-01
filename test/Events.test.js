const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EventApp", function () {
  let owner;
  let other_addr;
  let demo;
  let address;
  beforeEach(async function () {
    [owner, other_addr] = await ethers.getSigners();

    const EventContract = await ethers.getContractFactory("EventApp", owner);
    demo = await EventContract.deploy();
    await demo.waitForDeployment();
    address = await demo.getAddress();
    // console.log(`Addresss ${address}`);
  });

  async function sendMoney(sender) {
    const amount = 100;
    const txData = {
      to: address,
      value: amount,
    };

    const tx = await sender.sendTransaction(txData);
    await tx.wait();
    return [tx, amount];
  }

  it("should allow to send money", async function () {
    console.log("success2");
    const [sendMoneyTx, amount] = await sendMoney(other_addr);
    console.log(sendMoneyTx);

    await expect(() => sendMoneyTx).to.changeEtherBalance(demo, amount);

    const timestamp = (await ethers.provider.getBlock(sendMoneyTx.blockNumber))
      .timestamp;

    await expect(sendMoneyTx)
      .to.emit(demo, "Paid")
      .withArgs(other_addr.address, amount, timestamp);
  });

  it("should allow owner to withdraw funds", async function () {
    const [_, amount] = await sendMoney(other_addr);

    const tx = await demo.withdrawal(owner.address);

    await expect(() => tx).to.changeEtherBalances(
      [demo, owner],
      [-amount, amount]
    );
  });

  it("should not allow other accounts to withdraw funds", async function () {
    await sendMoney(other_addr);

    await expect(
      await demo.connect(other_addr).withdrawal(owner.address)
    ).to.be.revertedWith("you are not an owner");
  });
});
