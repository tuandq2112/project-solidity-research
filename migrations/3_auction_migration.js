const Token = artifacts.require("DuongTOKEN");
const Nft = artifacts.require("DUONGNFT");
const Auction = artifacts.require("Auction");

module.exports = function (deployer) {
    deployer.then(async () => {
        await deployer.deploy(Token);
        await deployer.deploy(Nft);
        await deployer.deploy(Auction, Nft.address, Token.address);
    });
    
};

