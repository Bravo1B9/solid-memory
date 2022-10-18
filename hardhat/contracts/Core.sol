// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { CliqueLib } from "./CliqueLib.sol";
import { UserLib } from "./UserLib.sol";
import { Clique } from "./Clique.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract Core {

    using UserLib for UserLib.User;
    UserLib.User user;

    using CliqueLib for CliqueLib.CliqueStruct;
    CliqueLib.CliqueStruct cliqueStruct;

    mapping(string => Clique) cliqueAddrs;
    mapping(address => bool) isClique;

    string[] public cliqueNames;

    mapping(bytes => mapping(address => bool)) hasVoted;

    function createClique(string memory _name, uint8 _communityType, uint8 _nftRestrictionStatus, IERC721 _nft) public {
        Core core = Core(address(this));
        Clique clique = new Clique(msg.sender, _name, core, _communityType, _nftRestrictionStatus, _nft);
        address cliqueAddress = address(clique);
        isClique[cliqueAddress] = true;
        cliqueAddrs[_name] = clique;
        cliqueStruct.addClique(clique);
        cliqueNames.push(_name);
    }

    function getAllCliques() external view returns (Clique[] memory) {
        return cliqueStruct.getAllCliques();
    }

    function getAllNames() external view returns (string[] memory) {
        return cliqueNames;
    }

    function getCliqueAddress(string memory _cliqueName) public view returns (Clique) {
        return cliqueAddrs[_cliqueName];
    }

    function addUserPostId(bytes memory _postId, address _user) external {
        require(isClique[msg.sender] == true, "Can only be called by a clique");
        user.addUserPostId(_postId, _user);
    }

    function addUserCommentId(bytes memory _commentId, address _user) external {
        require(isClique[msg.sender] == true, "Can only be called by a clique");
        user.addUserCommentId(_commentId, _user);
    }

    function getAllUserPostIds(address _user) external view returns (bytes[] memory) {
        return user.getAllUserPostIds(_user);
    }

    function getAllUserCommentIds(address _user) external view returns (bytes[] memory) {
        return user.getAllUserCommentIds(_user);
    }

    function getUserRep(address _user) external view returns (uint) {
        return user.getUserRep(_user);
    }

    function removeUserPostId(bytes memory _postId, address _user) external {
        user.removeUserPostId(_postId, _user);
    }

    function removeUserCommentId(bytes memory _commentId, address _user) external {
        user.removeUserCommentId(_commentId, _user);
    }
    
    function incUserRep(address _user) external {
        require(isClique[msg.sender] == true, "Can only be called by a clique");
        user.incRep(_user);
    }

    function decUserRep(address _user) external {
        require(isClique[msg.sender] == true, "Can only be called by a clique");
        user.decRep(_user);
    }
}