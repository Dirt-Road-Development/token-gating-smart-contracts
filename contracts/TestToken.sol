// SPDX-License-Identifer: MIT
pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
	constructor() ERC20("Name", "Symbol") {
		_mint(msg.sender, 100 * 10 ** 18);
	}

	function mint(address to) external {
		_mint(to, 100 * 10 ** 18);
	}
}