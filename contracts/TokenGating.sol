// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

type TokenId is uint256;
error InvalidTokenType();

contract TokenGating {

    enum TokenType {
        ERC20,
        ERC721,
        ERC1155
    }

    struct TokenOwnershipCheck {
        address tokenAddress;
        TokenType tokenType;
        uint256 tokenId;
        uint256 requiredBalance; // For ERC-20 or ERC-1155, ERC-721 Always 1
    }

    /**
     * Return an array of items
     */
    function canAccess(TokenOwnershipCheck[] memory checks, address userAddress) external view returns (bool[] memory) {
        bool[] memory isOwnedTokens = new bool[](checks.length);

        for (uint256 i = 0; i < checks.length; i++) {
            if (checks[i].tokenType == TokenType.ERC20) {
                isOwnedTokens[i] = IERC20(checks[i].tokenAddress).balanceOf(userAddress) >= checks[i].requiredBalance;
            } else if (checks[i].tokenType == TokenType.ERC721) {
                if (checks[i].tokenId == 0) {
                    isOwnedTokens[i] = IERC721(checks[i].tokenAddress).balanceOf(userAddress) == 1;
                } else {
                    isOwnedTokens[i] = IERC721(checks[i].tokenAddress).ownerOf(checks[i].tokenId) == userAddress;
                }
            } else if (checks[i].tokenType == TokenType.ERC1155) {
                isOwnedTokens[i] = IERC1155(checks[i].tokenAddress).balanceOf(userAddress, checks[i].tokenId) >= checks[i].requiredBalance;
            } else {
                revert InvalidTokenType();
            }
        }

        return isOwnedTokens;
    }

    /**
     * Require all be true else fail
     */
    function canAccessAggregate(TokenOwnershipCheck[] memory checks, address userAddress) external view returns (bool) {
        for (uint256 i = 0; i < checks.length; i++) {
            if (checks[i].tokenType == TokenType.ERC20) {
                if (IERC20(checks[i].tokenAddress).balanceOf(userAddress) < checks[i].requiredBalance) return false;
            } else if (checks[i].tokenType == TokenType.ERC721) {
                if (checks[i].tokenId == 0) {
                    if (IERC721(checks[i].tokenAddress).balanceOf(userAddress) != 1) return false;
                } else {
                    if (IERC721(checks[i].tokenAddress).ownerOf(checks[i].tokenId) != userAddress) return false;
                }
            } else if (checks[i].tokenType == TokenType.ERC1155) {
                if (IERC1155(checks[i].tokenAddress).balanceOf(userAddress, checks[i].tokenId) < checks[i].requiredBalance) return false;
            } else {
                revert InvalidTokenType();
            }
        }

        return true;
    }

}
