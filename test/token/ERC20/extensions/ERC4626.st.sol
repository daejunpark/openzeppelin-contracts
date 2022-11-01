// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "erc4626-tests/ERC4626.test.sol";

import {ERC20Mock} from "../../../../contracts/mocks/ERC20Mock.sol";
import {ERC4626Mock, IERC20Metadata} from "../../../../contracts/mocks/ERC4626Mock.sol";

contract ERC4626StdTest is ERC4626Test {

    function setUp() public override {
        __underlying__ = address(new ERC20Mock("MockERC20", "MockERC20", address(this), 0));
        __vault__ = address(new ERC4626Mock(IERC20Metadata(__underlying__), "MockERC4626", "MockERC4626"));
        __delta__ = 0;
        __vault_may_be_empty__ = false;
        __unlimited_amount__ = false;
    }

}
