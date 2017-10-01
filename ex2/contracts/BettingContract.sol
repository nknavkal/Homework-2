pragma solidity ^0.4.15;

contract BettingContract {
	/* Standard state variables */
	address owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint8 public numPlayers;
	uint[] outcomes;
	uint true_outcome;

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly()  {
		require(msg.sender == owner);
		_;
	}
	modifier OracleOnly() {
		require(msg.sender == oracle);
		_;
	}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) public {
		owner = msg.sender;
		outcomes = _outcomes;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) public OwnerOnly() returns (address) {
		oracle = _oracle;
		return oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) public payable returns (bool) {
		if (numPlayers < 2) {
			Bet memory myBet = Bet(_outcome, msg.value, true);
			bets[msg.sender] = myBet;
			numPlayers += 1;
			if (numPlayers < 1) {
				gamblerA = msg.sender;
			}	else {
				gamblerB = msg.sender;
			}
			BetMade(msg.sender);
			return true;
		} else {
			return false;
		}
				//Bet myBet;
		//myBet.outcome = _outcome;
		//myBet.amount = _amount;
		//myBet.initialized = true;

	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) public OracleOnly() {
		true_outcome = _outcome;
		Bet memory betA = bets[gamblerA];
		Bet memory betB = bets[gamblerB];
		if (betA.outcome == betB.outcome) {
			winnings[gamblerA] = betA.amount;
			winnings[gamblerB] = betB.amount;
		} else {
			uint _winnings = betA.amount + betB.amount;
			if (betA.outcome == true_outcome) {
				winnings[gamblerA] = _winnings;
			} else if (betB.outcome == true_outcome) {
				winnings[gamblerB] = _winnings;
			} else {
				winnings[oracle] = _winnings;
			}
		}
		BetClosed();
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) public returns (uint remainingBal) {
		if (withdrawAmount > winnings[msg.sender]) {
			winnings[msg.sender] = 0;
			msg.sender.transfer(winnings[msg.sender]);
		} else {
			winnings[msg.sender] -= withdrawAmount;
			msg.sender.transfer(withdrawAmount);
		}
		return winnings[msg.sender];
	}

	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() public constant returns (uint[]) {
		return outcomes;
	}

	/* Allow anyone to check if they won any bets */
	function checkWinnings() public constant returns(uint) {
		return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
		delete(oracle);
		delete(bets[gamblerA]);
		delete(bets[gamblerB]);
		delete(winnings[gamblerA]);
		delete(winnings[gamblerB]);
		delete(true_outcome);
		delete(numPlayers);
		delete(gamblerA);
		delete(gamblerB);
	}

	/* Fallback function */
	function() public {
		revert();
	}
}
