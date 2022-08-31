const VerifyMessageAndReward = artifacts.require("VerifyMessageAndReward");

module.exports = function (deployer) {
  deployer.deploy(VerifyMessageAndReward);
};
