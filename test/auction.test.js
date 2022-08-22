const Token = artifacts.require("DuongTOKEN");
const NFT = artifacts.require("DUONGNFT");
const Auction = artifacts.require("Auction");


const { time } = require("@openzeppelin/test-helpers");

var snapshotId;
var token;
var nft;
var auction;
contract("Auction", (accounts) => {
  before(async () => {
    token = await Token.deployed();
    nft = await NFT.deployed();
    auction = await Auction.deployed();
  });

  describe("test", function () {
    const owner = accounts[0];
    const ownerNFT = accounts[1];
    const auctioneer_1 = accounts[2];
    const auctioneer_2 = accounts[3];
    const duration = time.duration.seconds(120);
    const priceStart = 100;
    const tokenId = 1;
    const itemId = 1;

    describe("makeItem", function () {
      before(async () => {
        await nft.createNFT(ownerNFT, "nguyen duong 0", { from: ownerNFT });
        await nft.approve(auction.address, tokenId, { from: ownerNFT });
      });
      it("check string URI of nft", async () => {
        let str = await nft.tokenURI(tokenId);
        assert.equal(str, "nguyen duong 0");
      });
      it("check owner of NFT", async () => {
        // snapshotId = await provider.send("evm_snapshot");
        let owner = await nft.ownerOf(tokenId);
        assert.equal(owner, ownerNFT);
      });
      it("check make item auction", async () => {
        await auction.makeItem(tokenId, priceStart, duration, {
          from: ownerNFT,
        });
      });
      it("check price highest", async () => {
        let price = await auction.getPriceHighestCurrent(itemId);
        assert.equal(price, 100);
      });
      it("check fail: call makeItem again", async () => {
        let err = null;
        try {
          await auction.makeItem(tokenId, priceStart, duration, {
            from: ownerNFT,
          });
        } catch (error) {
          err = error;
        }
        assert.ok(err instanceof Error);
      });
    });

    describe("bidAuction", function() {
        before(async() => {
            await token.mintToken(auctioneer_1, 1000, {from: owner});
            await token.mintToken(auctioneer_2, 1000, {from: owner});

            await token.approve(auction.address, 1000, {from: auctioneer_1});
            await token.approve(auction.address, 1000, {from: auctioneer_2});
        })
        it("check balanceOf auctioneer_1", async() => {
            let balance = await token.balanceOf(auctioneer_1);
            assert.equal(balance, 1000);
        })
        it("check balanceOf auctioneer_2", async() => {
            let balance = await token.balanceOf(auctioneer_2);
            assert.equal(balance, 1000);
        })
        it("check allowance auctioneer_1", async() => {
            let balance = await token.allowance(auctioneer_1, auction.address);
            assert.equal(balance, 1000);
        })
        it("check allowance auctioneer_2", async() => {
            let balance = await token.allowance(auctioneer_2, auction.address);
            assert.equal(balance, 1000);
        })
        it("check fail: set price auction < priceStart", async() => {
            let err = null;
            try {
                await auction.bidAuction(itemId, priceStart - 1, {from: auctioneer_1});
            } catch(error) {
                err = error;
            }
            assert.ok(err instanceof Error);
        })
        it("check set price auction > priceStart and auction time is not over yet", async() => {
            await auction.bidAuction(itemId, priceStart + 20, {from: auctioneer_1});
            let balance = await token.balanceOf(auctioneer_1);
            let priceHighest = await auction.getPriceHighestCurrent(itemId);
            assert.equal(balance, 1000 - (priceStart + 20));
            assert.equal(priceHighest, priceStart + 20);
        })
        it("check fail: set price lower than current priceHighest", async () => {
            let err = null;
            try {
                await auction.bidAuction(itemId, priceStart + 10, {from: auctioneer_2});
            } catch(error) {
                err = error;
            }
            assert.ok(err instanceof Error);
        })
        it("check set price higher than current priceHighest", async () => {
            await auction.bidAuction(itemId, priceStart + 30, {from: auctioneer_2});
            let balance_1 = await token.balanceOf(auctioneer_1);
            let balance_2 = await token.balanceOf(auctioneer_2);
            let priceHighest = await auction.getPriceHighestCurrent(itemId);
            assert.equal(balance_1, 1000);
            assert.equal(balance_2, 1000 - (priceStart + 30));
            assert.equal(priceHighest, priceStart + 30);
        })
        
        // it("check fail: set price auction > priceStart BUT time auction ended", async() => {
        //     let err = null;
        //     try {
        //         let timeRun = time.duration.seconds(duration + 5);
        //         await time.increase(timeRun);
        //         await auction.bidAuction(itemId, priceStart + 1, {from: auctioneer_1});
        //     } catch(error) {
        //         err = error;
        //     }
        //     assert.ok(err instanceof Error);
        // })
    })
  });
});
