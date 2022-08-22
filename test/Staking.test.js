const Staking = artifacts.require("StakingRewards");
const Token = artifacts.require("SampleERC20");
const amountMint = 5000;
const amountApprove = 3000;
const amountStake = 1000;
const amountRewards = 5000;
const durationTest = 30;
const StakingRate = 1.1;
const { time, balance } = require("@openzeppelin/test-helpers");
var balanceStakerBeforeStake;

contract("SampleERC20", (account) => {
  before(async () => {
    instanceToken = await Token.deployed();
  });

  it("Name token check", async () => {
    let name = await instanceToken.name();
    assert.equal(name, "BenCoin", "Token name should be BenCoin");
  });
});

contract("StakingRewards", (account) => {
  before(async () => {
    instanceToken = await Token.deployed();
    instanceStaking = await Staking.deployed();
    stakingAddress = instanceStaking.address;
  });

  describe("Duration staking check", function () {
    it("Duration check 1", async () => {
      let duration = await instanceStaking.duration();
      assert.equal(
        duration,
        durationTest,
        "Duration staking should last 30 seconds"
      );
    });
    it("Duration check 2", async () => {
      let duration = await instanceStaking.duration();
      assert.notEqual(
        duration,
        durationTest - 1,
        "Duration staking should last 30 seconds"
      );
    });
  });
  describe("Stake checking", function () {
    contract("Stake check 1", function () {
      before(async () => {
        await instanceToken.mint(account[1], amountMint);
        await instanceToken.approve(instanceStaking.address, amountApprove, {
          from: account[1],
        });
      });
      describe("Check time end stake", function () {
        it("Check run stake when already stake (time end stake not equal 0)", async () => {
          await instanceStaking.stake(amountStake, { from: account[1] });
          await time.increase(durationTest - 5);
          let err = null;
          try {
            await instanceStaking.stake(amountStake, { from: account[1] });
          } catch (error) {
            err = error;
          }
          assert.ok(err instanceof Error);
        });
      });
    });
    contract("Stake check 2", function () {
      before(async () => {
        await instanceToken.mint(account[1], amountMint);
        await instanceToken.approve(instanceStaking.address, amountApprove, {
          from: account[1],
        });
      });
      describe("Check balance", function () {
        it("Check balance stake of user after staking", async () => {
          await instanceStaking.stake(amountStake, { from: account[1] });
          let balance = await instanceStaking.getBalanceStakeOf(account[1]);
          assert.equal(
            amountStake,
            balance,
            "Balance should equal amountStake"
          );
        });
      });
    });
    contract("Stake check 3", function () {
      before(async () => {
        await instanceToken.mint(account[1], amountMint);
        await instanceToken.approve(instanceStaking.address, amountApprove, {
          from: account[1],
        });
      });
      describe("Check amount", function () {
        it("Check function stake if amount stake exceed amount approve ", async () => {
          let err = null;
          try {
            await instanceStaking.stake(amountApprove + 1, {
              from: account[1],
            });
          } catch (error) {
            err = error;
          }
          assert.ok(err instanceof Error);
        });
      });
    });
  });

  describe("withdrawFulltime checking", function () {
    contract("withdrawFulltime check 1", function () {
      before(async () => {
        await instanceToken.mint(account[1], amountMint);
        await instanceToken.approve(instanceStaking.address, amountApprove, {
          from: account[1],
        });
        await instanceStaking.stake(amountStake, { from: account[1] });
      });
      describe("Check time", function () {
        it("Check function when duration of staking is not over yet", async () => {
          await time.increase(durationTest - 5);
          let err = null;
          try {
            await instanceStaking.withdrawFulltime({ from: account[1] });
          } catch (error) {
            err = error;
          }
          assert.ok(err instanceof Error);
        });
      });
    });
    contract("withdrawFulltime check 2", function () {
      before(async () => {
        await instanceToken.mint(account[1], amountMint);
        await instanceToken.approve(instanceStaking.address, amountApprove, {
          from: account[1],
        });
        await instanceStaking.stake(amountStake, { from: account[1] });
        await instanceToken.mint(stakingAddress, 50);
      });
      describe("Check balance", function () {
        it("Check if balance of pool not enough to pay reward for staker", async () => {
          await time.increase(durationTest);
          let err = null;
          try {
            await instanceStaking.withdrawFulltime({ from: account[1] });
          } catch (error) {
            err = error;
          }
          assert.ok(err instanceof Error);
        });
      });
    });
    contract("withdrawFulltime check 3", function () {
      before(async () => {
        await instanceToken.mint(account[1], amountMint);
        balanceStakerBeforeStake = await instanceToken.balanceOf(account[1]);
        await instanceToken.approve(instanceStaking.address, amountApprove, {
          from: account[1],
        });
        await instanceStaking.stake(amountStake, { from: account[1] });
        await instanceToken.mint(stakingAddress, amountRewards);
      });
      describe("Check reward of staker", function () {
        it("Check reward of staker after withdraw", async () => {
          let balanceStake = await instanceStaking.getBalanceStakeOf(
            account[1]
          );
          let trueReward = (balanceStake * 10) / 100;
          await time.increase(durationTest);
          await instanceStaking.withdrawFulltime({ from: account[1] });
          let balanceStakerAfterGetReward = await instanceToken.balanceOf(
            account[1]
          );
          let rewardStakerGetAfterWithdraw =
            balanceStakerAfterGetReward - balanceStakerBeforeStake;
          assert.equal(
            trueReward.toString(10),
            rewardStakerGetAfterWithdraw.toString(10),
            "Reward should be pay correct"
          );
        });
      });
      describe("Check resetStakeOfUser", function () {
        it("Check time end stake of user after run function withdrawFulltime", async () => {
          let timeEndStakeOfUser = await instanceStaking.getTimeEndStake(
            account[1]
          );
          assert.equal(
            timeEndStakeOfUser,
            0,
            "time end stake of user should equal 0 after run function withdrawFulltime"
          );
        });
        it("Check balance stake of user after run function withdrawFulltime", async () => {
          let balanceStakeOfUser = await instanceStaking.getBalanceStakeOf(
            account[1]
          );
          assert.equal(
            balanceStakeOfUser,
            0,
            "balance stake of user should equal 0 after run function withdrawFulltime"
          );
        });
      });
    });
  });

  describe("forceWithdraw checking", function () {
    contract("forceWithdraw check 1", function () {
      before(async () => {
        await instanceToken.mint(account[1], amountMint);
        balanceStakerBeforeStake = await instanceToken.balanceOf(account[1]);
        await instanceToken.approve(instanceStaking.address, amountApprove, {
          from: account[1],
        });
        await instanceStaking.stake(amountStake, { from: account[1] });
        await instanceToken.mint(stakingAddress, amountRewards);
      });
      describe("Check balance staker", function () {
        it("Check balance staker after force withdraw", async () => {
          await time.increase(durationTest - 10);
          await instanceStaking.forceWithdraw({ from: account[1] });
          let balanceStakerAfterForceWithdraw = await instanceToken.balanceOf(
            account[1]
          );
          assert.equal(
            balanceStakerBeforeStake.toString(10),
            balanceStakerAfterForceWithdraw.toString(10),
            "Balance after force withdraw should equal balance before stake"
          );
        });
      });
      describe("Check resetStakeOfUser", function () {
        it("Check time end stake of user after run function forceWithdraw", async () => {
          let timeEndStakeOfUser = await instanceStaking.getTimeEndStake(
            account[1]
          );
          assert.equal(
            timeEndStakeOfUser,
            0,
            "time end stake of user should equal 0 after run function forceWithdraw"
          );
        });
        it("Check balance stake of user after run function forceWithdraw", async () => {
          let balanceStakeOfUser = await instanceStaking.getBalanceStakeOf(
            account[1]
          );
          assert.equal(
            balanceStakeOfUser,
            0,
            "balance stake of user should equal 0 after run function forceWithdraw"
          );
        });
      });
    });
  });
});
