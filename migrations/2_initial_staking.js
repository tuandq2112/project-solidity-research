const Staking = artifacts.require("StakingRewards");
const ERC20token = artifacts.require("SampleERC20");

module.exports = function (deployer) {
  deployer.deploy(ERC20token).then(
    function(){
      return deployer.deploy(Staking,ERC20token.address)
    }
  );
};
