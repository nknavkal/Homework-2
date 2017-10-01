var BettingContract = artifacts.require("./BettingContract.sol");

module.exports = function(deployer) {
	/* Input value to constructor on contract deployment */
	const testOutcomes = [1, 2, 3];
	deployer.deploy(BettingContract, testOutcomes);
};
