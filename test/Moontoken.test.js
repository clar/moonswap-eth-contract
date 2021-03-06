const { expectRevert } = require('@openzeppelin/test-helpers');
const MoonToken = artifacts.require('MoonToken');

contract('MoonToken', ([alice, bob, carol, donas]) => {
    beforeEach(async () => {
        this.moonToken = await MoonToken.new({ from: alice });
    });

    it('should votes test', async () => {
        const name = await this.moonToken.name();
        const symbol = await this.moonToken.symbol();
        const decimals = await this.moonToken.decimals();
        assert.equal(name.valueOf(), 'MoonToken');
        assert.equal(symbol.valueOf(), 'MOON');
        assert.equal(decimals.valueOf(), '18');

        await this.moonToken.mint(alice, '100', { from: alice });
        await this.moonToken.delegate(donas, {from: alice});
        await this.moonToken.transfer(bob, '100', {from: alice} );
        await this.moonToken.delegate(donas, {from: bob});
        await this.moonToken.transfer(carol, '100', {from: bob} );
        await this.moonToken.delegate(donas, {from: carol});
        await this.moonToken.transfer(alice, '100', {from: carol} );
        console.log("alice balance=>", (await this.moonToken.balanceOf(alice)).toString());
        console.log("bob balance=>", (await this.moonToken.balanceOf(bob)).toString());
        console.log("carol balance=>", (await this.moonToken.balanceOf(carol)).toString());
        console.log("totalSupply", (await this.moonToken.totalSupply()).toString());
        console.log("donas votes", (await this.moonToken.getCurrentVotes(donas)).toString());
    });

  });
