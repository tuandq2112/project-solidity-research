const Staking = artifacts.require("StakingRewards");
const Token = artifacts.require("SampleERC20");
const amountMint = 5000;
const amountApprove = 3000;
const amountStake = 1000;
const amountRewards = 5000;
const durationTest = 30;
const StakingRate = 1.1;
const { time } = require("@openzeppelin/test-helpers");
var balanceStakerBeforeStake;

contract("StakingRewards", (account) => {
  before(async () => {
    instanceToken = await Token.deployed();
    instanceStaking = await Staking.deployed();
    stakingAddress = instanceStaking.address;
  });
  contract("withdrawFulltime check 3", function () {
    before(async () => {
      await instanceToken.mint(account[1], amountMint);
      balanceStakerBeforeStake = await instanceToken.balanceOf(
        account[1]
      );
      await instanceToken.approve(instanceStaking.address, amountApprove, {
        from: account[1],
      });
      await instanceStaking.stake(amountStake, { from: account[1] });
      await instanceToken.mint(stakingAddress, amountRewards);
    });
    describe("Check reward of staker", function () {
      it("Check reward of staker after withdraw", async () => {
        let balanceStake = await instanceStaking.getBalanceStakeOf(account[1]);
        let trueReward = balanceStake * 10 / 100;
        console.log(trueReward.toString(10), "trueReward");
        await time.increase(durationTest);

        await instanceStaking.withdrawFulltime({ from: account[1] });

        let balanceStakerAfterGetReward = await instanceToken.balanceOf(
          account[1]
        );
        let rewardStakerGetAfterWithdraw =
          balanceStakerAfterGetReward - balanceStakerBeforeStake;
        console.log(
          rewardStakerGetAfterWithdraw.toString(10),
          "rewardStakerGetAfterWithdraw"
        );
        assert.equal(
          trueReward.toString(10),
          rewardStakerGetAfterWithdraw.toString(10),
          "Reward should be pay correct"
        );
      });
    });
  });
});
