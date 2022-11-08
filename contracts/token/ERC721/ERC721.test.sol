// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

contract ERC721Test is ERC721 {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) { }

    //
    // mint
    //

    // TODO: duplicate spec for _safeMint
    function mint(address to, uint tokenId) public {
        _mint(to, tokenId);
      //_safeMint(to, tokenId);
      //_safeMint(to, tokenId, data);
    }

    function test_mint_requirements(address to, uint tokenId) public {
        bool exists = _exists(tokenId);

        mint(to, tokenId);

        unchecked {
            assert(to != address(0));
            assert(!exists);
        }
    }

    function test_mint_balance_update(address to, uint tokenId) public {
        uint oldBalanceTo = balanceOf(to);
        require(oldBalanceTo < type(uint).max); // practical assumption needed for overflow/underflow not occurring

        mint(to, tokenId);

        uint newBalanceTo = balanceOf(to);

        unchecked {
            assert(newBalanceTo > oldBalanceTo); // ensuring no overflow
            assert(newBalanceTo == oldBalanceTo + 1);
        }
    }

    function test_mint_ownership_update(address to, uint tokenId) public {
        mint(to, tokenId);

        unchecked {
            assert(_ownerOf(tokenId) == to);
            assert(_exists(tokenId));
        }
    }

    function test_mint_other_balance_preservation(address to, uint tokenId, address others) public {
        require(others != to); // consider other addresses

        uint oldBalanceOther = balanceOf(others);

        mint(to, tokenId);

        uint newBalanceOther = balanceOf(others);

        unchecked {
            assert(newBalanceOther == oldBalanceOther); // the balance of other addresses never change
        }
    }

    function test_mint_other_ownership_preservation(address to, uint tokenId, uint otherTokenId) public {
        require(otherTokenId != tokenId); // consider other token ids

        address oldOtherTokenOwner = _ownerOf(otherTokenId);
        bool oldExists = _exists(otherTokenId);

        mint(to, tokenId);

        address newOtherTokenOwner = _ownerOf(otherTokenId);
        bool newExists = _exists(otherTokenId);

        unchecked {
            assert(oldOtherTokenOwner == newOtherTokenOwner); // the owner of other token ids never change
            assert(newExists == oldExists);
        }
    }

    //
    // burn
    //
    // TODO: duplicate spec for both modes
    function burn(uint tokenId) public {
        _burn(tokenId);
    }

    function test_burn_requirements(uint tokenId) public {
        bool exist = _exists(tokenId);

        burn(tokenId);

        unchecked {
            assert(exist); // it should have reverted if the token id does not exist
        }
    }

    function test_burn_balance_update(uint tokenId) public {
        address from = _ownerOf(tokenId);
        uint oldBalanceFrom = balanceOf(from);

        require(oldBalanceFrom > 0); // NOTE: assumption required for correctness

        burn(tokenId);

        uint newBalanceFrom = balanceOf(from);

        unchecked {
            assert(newBalanceFrom < oldBalanceFrom); // ensuring no overflow
            assert(newBalanceFrom == oldBalanceFrom - 1);
        }
    }

    function test_burn_ownership_update(uint tokenId) public {
        burn(tokenId);

        unchecked {
            assert(!_exists(tokenId));
        }
    }

    function test_burn_other_balance_preservation(uint tokenId, address others) public {
        address from = _ownerOf(tokenId);
        require(others != from); // consider other addresses

        uint oldBalanceOther = balanceOf(others);

        burn(tokenId);

        uint newBalanceOther = balanceOf(others);

        unchecked {
            assert(newBalanceOther == oldBalanceOther);
        }
    }

    function test_burn_other_ownership_preservation(uint tokenId, uint otherTokenId) public {
        require(otherTokenId != tokenId); // consider other token ids

        address oldOtherTokenOwner = _ownerOf(otherTokenId);
        bool oldExists = _exists(otherTokenId);

        burn(tokenId);

        address newOtherTokenOwner = _ownerOf(otherTokenId);
        bool newExists = _exists(otherTokenId);

        unchecked {
            assert(newOtherTokenOwner == oldOtherTokenOwner);
            assert(newExists == oldExists);
        }
    }

    //
    // transfer
    //

    // TODO: duplicate spec for safeTransferFrom
    function transfer(address from, address to, uint tokenId) public {
        transferFrom(from, to, tokenId);
      //safeTransferFrom(from, to, tokenId);
      //safeTransferFrom(from, to, tokenId, data);
    }

    function test_transfer_requirements(address from, address to, uint tokenId) public {
        bool exist = _exists(tokenId);

        address owner = _ownerOf(tokenId);
        bool approved = msg.sender == getApproved(tokenId) || isApprovedForAll(owner, msg.sender);

        transfer(from, to, tokenId);

        unchecked {
            assert(exist); // it should have reverted if the token id does not exist

            assert(from != address(0));
            assert(to != address(0));

            assert(from == owner);
            assert(msg.sender == owner || approved);

            assert(getApproved(tokenId) == address(0));
        }
    }

    function test_transfer_balance_update(address from, address to, uint tokenId) public {
        require(from != to); // consider normal transfer case (see below for the self-transfer case)

        uint oldBalanceFrom = balanceOf(from);
        uint oldBalanceTo   = balanceOf(to);

        require(oldBalanceFrom > 0); // NOTE: assumption required for correctness
        require(oldBalanceTo < type(uint).max); // practical assumption needed for overflow/underflow not occurring

        transfer(from, to, tokenId);

        uint newBalanceFrom = balanceOf(from);
        uint newBalanceTo   = balanceOf(to);

        unchecked {
            assert(newBalanceFrom < oldBalanceFrom);
            assert(newBalanceFrom == oldBalanceFrom - 1);

            assert(newBalanceTo > oldBalanceTo);
            assert(newBalanceTo == oldBalanceTo + 1);
        }
    }

    function test_transfer_balance_unchanged(address from, address to, uint tokenId) public {
        require(from == to); // consider self-transfer case

        uint oldBalance = balanceOf(from); // == balanceOf(to);

        transfer(from, to, tokenId);

        uint newBalance = balanceOf(from); // == balanceOf(to);

        unchecked {
            assert(newBalance == oldBalance);
        }
    }

    function test_transfer_ownership_update(address from, address to, uint tokenId) public {
        transfer(from, to, tokenId);

        unchecked {
            assert(_ownerOf(tokenId) == to);
            assert(_exists(tokenId));
        }
    }

    function test_transfer_other_balance_preservation(address from, address to, uint tokenId, address others) public {
        require(others != from); // consider other addresses
        require(others != to);

        uint oldBalanceOther = balanceOf(others);

        transfer(from, to, tokenId);

        uint newBalanceOther = balanceOf(others);

        unchecked {
            assert(newBalanceOther == oldBalanceOther);
        }
    }

    function test_transfer_other_ownership_preservation(address from, address to, uint tokenId, uint otherTokenId) public {
        require(otherTokenId != tokenId); // consider other token ids

        address oldOtherTokenOwner = _ownerOf(otherTokenId);
        bool oldExists = _exists(otherTokenId);

        transfer(from, to, tokenId);

        address newOtherTokenOwner = _ownerOf(otherTokenId);
        bool newExists = _exists(otherTokenId);

        unchecked {
            assert(newOtherTokenOwner == oldOtherTokenOwner);
            assert(newExists == oldExists);
        }
    }
}
