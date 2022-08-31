const Token = artifacts.require("IvirseToken");
const VerifyMessageAndReward = artifacts.require("VerifyMessageAndReward");

const { ethers } = require("ethers");

var creactVouchers = async (add, size) => {
  var Wallet = ethers.Wallet;
  var privateKey =
    "ddeeb92dede42f78a60be90ea7d53c2258863521c2af8b58b9f18a5e76fa44af";
  var wallet = new Wallet(privateKey);

  let time = await Math.floor(Date.now() / 1000);
  let arr = [];
  for (let i = 0; i < size; i++) {
    let timestamp = time + i;
    let message = `${add.toLowerCase()}${i.toString()}${timestamp.toString()}`;
    const signature = await wallet.signMessage(message);
    let obj = {
      add: add,
      amount: i.toString(),
      timestamp: timestamp.toString(),
      sign: signature,
    };
    arr.push(obj);
  }
  return arr;
};

var token;
var verifyMessageAndReward;
contract("VerifyMessageAndReward", (accounts) => {
  before(async () => {
    token = await Token.deployed();
    verifyMessageAndReward = await VerifyMessageAndReward.deployed();
  });

  describe("test with 1 acc, 1 voucher", function () {
    var arr_1 = [];
    var size = 100;

    // stt == amount of voucher == index arr
    var stt = 4;
    before(async () => {
      await token.mint(verifyMessageAndReward.address, 9000000);
      arr_1 = await creactVouchers(accounts[1], size);
    });
    it("reward 1 voucher and check balanceOf", async () => {
      await verifyMessageAndReward.rewardToken(
        arr_1[stt].add,
        arr_1[stt].amount,
        arr_1[stt].timestamp,
        arr_1[stt].sign
      );
      let balance = await token.balanceOf(accounts[1]);
      assert.equal(balance, stt);
    });
    it("recall voucher used", async () => {
      let err = null;
      try {
        await verifyMessageAndReward.rewardToken(
          arr_1[stt].add,
          arr_1[stt].amount,
          arr_1[stt].timestamp,
          arr_1[stt].sign
        );
      } catch (error) {
        err = error;
      }
      assert.ok(err instanceof Error);
    });
  });
  describe("test with 1 acc, 100 voucher", async () => {
    var arr_2 = [];
    var size = 100;
    before(async() => {
      await token.mint(verifyMessageAndReward.address, 9000000);
      arr_2 = await creactVouchers(accounts[2], size);
    })
    it("continuously pay 100 vouchers", async() => {
      let amountCheck = (size-1) * (size) / 2;
      for(let i = 0; i < size; i ++) {
        await verifyMessageAndReward.rewardToken(
          arr_2[i].add,
          arr_2[i].amount,
          arr_2[i].timestamp,
          arr_2[i].sign
        );
      }
      let balance = await token.balanceOf(accounts[2]);
      assert.equal(amountCheck, balance);
    })
  });
});
