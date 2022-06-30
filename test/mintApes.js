const JackedApes = artifacts.require("JackedApeClub");
const PumpToken = artifacts.require("PumpTokenERC20");
const Staking = artifacts.require("Stakeable");

contract("JackedApesClub NFT contract", accounts => {
    const [deployerAddress, HolderOne, HolderTwo, HolderThree, HolderFour, HolderFive] = accounts;

    it("Is possible to mint tokens", async () => {
        const jac = await JackedApes.deployed();

        await jac.mint(1, {from: HolderOne})
        await jac.mint(2, {from: HolderTwo})
        await jac.mint(3, {from: HolderThree})
        await jac.mint(4, {from: HolderFour})
        await jac.mint(5, {from: HolderFive})

        let holderOneBalance = await jac.balanceOf(HolderOne);
        let holderTwoBalance = await jac.balanceOf(HolderTwo);
        let holderThreeBalance = await jac.balanceOf(HolderThree);
        let holderFourBalance = await jac.balanceOf(HolderFour);
        let holderFiveBalance = await jac.balanceOf(HolderFive);

        assert.equal(holderOneBalance, 1);
        assert.equal(holderTwoBalance, 2);
        assert.equal(holderThreeBalance, 3);
        assert.equal(holderFourBalance, 4);
        assert.equal(holderFiveBalance, 5);

    });

    it("Can stake and unstake a single NFT", async () => {
        const jac = await JackedApes.deployed();
        const staking = await Staking.deployed();

        let holderOneBalance = await jac.balanceOf(HolderOne);

        await jac.setApprovalForAll(staking.address, true, {from: HolderOne});
        await staking.stake(1, {from: HolderOne});

        holderOneBalance = await jac.balanceOf(HolderOne);
        assert.equal(holderOneBalance, 0);

        await staking.unstake(1, {from: HolderOne});

        holderOneBalance = await jac.balanceOf(HolderOne);
        assert.equal(holderOneBalance, 1);
    });

    it("Can stake in batches", async () => {
        const jac = await JackedApes.deployed();
        const staking = await Staking.deployed();

        await jac.setApprovalForAll(staking.address, true, {from: HolderTwo});
        await jac.setApprovalForAll(staking.address, true, {from: HolderThree});
        await jac.setApprovalForAll(staking.address, true, {from: HolderFour});
        await jac.setApprovalForAll(staking.address, true, {from: HolderFive});

        await staking.stakeBatch([1], {from: HolderOne});
        await staking.stakeBatch([2,3], {from: HolderTwo});
        await staking.stakeBatch([4,5,6], {from: HolderThree});
        await staking.stakeBatch([7,8,9,10], {from: HolderFour});
        await staking.stakeBatch([11,12,13,14,15], {from: HolderFive});

        holderFiveBalance = await jac.balanceOf(HolderFive);
        assert.equal(holderFiveBalance, 0);
    });

    it("Unstakes in batches", async () => {
        const jac = await JackedApes.deployed();
        const staking = await Staking.deployed();

        await staking.unstakeBatch([1], {from: HolderOne});
        await staking.unstakeBatch([2,3], {from: HolderTwo});
        await staking.unstakeBatch([4,5,6], {from: HolderThree});
        await staking.unstakeBatch([7,8,9,10], {from: HolderFour});
        await staking.unstakeBatch([11,12,13,14,15], {from: HolderFive});
        
        holderFiveBalance = await jac.balanceOf(HolderFive);
        assert.equal(holderFiveBalance, 5);
    });

    it("Tracks token yield over time", async () => {
        const staking = await Staking.deployed();

        holderOneYields = await staking.getYields(HolderOne);
        holderTwoYields = await staking.getYields(HolderTwo);
        holderThreeYields = await staking.getYields(HolderThree);
        holderFourYields = await staking.getYields(HolderFour);
        holderFiveYields = await staking.getYields(HolderFive);

        //assert.isAbove(holderTwoYields, holderOneYields);
        //assert.isAbove(holderThreeYields, holderTwoYields);
        //assert.isAbove(holderFourYields, holderThreeYields);
        //assert.isAbove(holderFiveYields, holderFourYields);
        console.log(holderOneYields.toNumber());
        console.log(holderTwoYields.toNumber());
        console.log(holderThreeYields.toNumber());
        console.log(holderFourYields.toNumber());
        console.log(holderFiveYields.toNumber());

    });
});