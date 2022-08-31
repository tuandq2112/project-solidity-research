const VerifyMessageAndReward = artifacts.require("VerifyMessageAndReward");
const IvirseToken = artifacts.require("IvirseToken");

const addrPubServer = "0x869e126b3BcF897371468E4e9108aCF0542f9d53";

module.exports = async (deployer) => {
  await deployer.deploy(IvirseToken);
  await deployer.deploy(VerifyMessageAndReward, IvirseToken.address, addrPubServer);
};
