// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { CliquePubsLib } from "./CliquePubsLib.sol";
import { CliqueMemberLib } from "./CliqueMemberLib.sol";
import { Core } from "./Core.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract Clique {

    Core core;
    IERC721 nft;

    using CliquePubsLib for CliquePubsLib.Post;
    CliquePubsLib.Post post;

    using CliqueMemberLib for CliqueMemberLib.CliqueMember;
    CliqueMemberLib.CliqueMember member;

    string public cliqueName;
    mapping(address => bool) isAdmin;
    mapping(bytes => address) postIdToUser;
    mapping(bytes => address) commentIdToUser;

    modifier onlyPostCreatorOrAdmin(bytes memory _postId) {
        require(msg.sender == postIdToUser[_postId]
        ||
        isAdmin[msg.sender] == true,
        "Caller is not post creator or admin");
        _;
    }

    modifier onlyAdmin(address _addr) {
        require(isAdmin[_addr] == true, "Caller is not admin");
        _;
    }

    enum CommunityType {
        Public,
        Restricted,
        Private
    }

    enum NFTRestrictionStatus {
        Restricted,
        Open
    }

    NFTRestrictionStatus public nftRestrictionStatus;
    CommunityType public communityType;

    constructor(address _userAddr, string memory _name, Core _core, uint8 _communityType, uint8 _nftRestrictionStatus, IERC721 _nft) {
        isAdmin[_userAddr] = true;
        member.add(_userAddr);
        cliqueName = _name;
        core = _core;
        CommunityType commType = CommunityType(_communityType);
        communityType = commType;
        NFTRestrictionStatus nftResStatus = NFTRestrictionStatus(_nftRestrictionStatus);
        nftRestrictionStatus = nftResStatus;
        nft = _nft;
    }

    function setCommunityType(CommunityType _communityType) public onlyAdmin(msg.sender) {
        communityType = _communityType;
    }

    function setNFTRestrictionStatus(NFTRestrictionStatus _restrictionStatus) external onlyAdmin(msg.sender) {
        nftRestrictionStatus = _restrictionStatus;
    } 

    function getNFTRestrictionStatus() public view returns (uint8) {
        uint8 nftResStatus = uint8(nftRestrictionStatus);
        return nftResStatus;
    }

    function setName(string memory _name) public onlyAdmin(msg.sender) {
        cliqueName = _name;
    }

    function getName() external view returns (string memory) {
        return cliqueName;
    }

    function addAdmin(address _member) public onlyAdmin(msg.sender) {
        isAdmin[_member] = true;
    }

    function removeAdmin(address _member) external onlyAdmin(msg.sender) {
        delete isAdmin[_member];
    }

    function addPostId(bytes memory _postId) external {
        if(_getCommunityType() == 1 || _getCommunityType() == 2) {
            require(member.isMember[msg.sender] == true, "Only clique members may post content to this clique");
        }
        if(getNFTRestrictionStatus() == 1) {
            require(nft.balanceOf(msg.sender) >= 1, "Caller does not own the required nft");
        }
        core.addUserPostId(_postId, msg.sender);
        postIdToUser[_postId] = msg.sender;
        post.addPostId(_postId);
        upvotePostId(_postId, msg.sender);
    }

    function addCommentId(bytes memory _postId, bytes memory _commentId) external {
        if(_getCommunityType() == 1 || _getCommunityType() == 2) {
            require(member.isMember[msg.sender] == true, "Only clique members may post content to this clique");
        }
        if(getNFTRestrictionStatus() == 1) {
            require(nft.balanceOf(msg.sender) >= 1, "Caller does not own the required nft");
        }
        core.addUserCommentId(_commentId, msg.sender);
        commentIdToUser[_commentId] = msg.sender;
        post.addCommentId(_postId, _commentId);
        core.incUserRep(msg.sender);
    }

    function removePostId(bytes memory _postId) external onlyAdmin(msg.sender) {
        core.removeUserPostId(_postId, msg.sender);
        post.removePost(_postId);
    }

    function removeCommentId(bytes memory _postId, bytes memory _commentId) external onlyAdmin(msg.sender) {
        core.removeUserCommentId(_commentId, msg.sender);
        post.removeComment(_postId, _commentId);
    }

    function getAllCliquePostIds() external view returns (bytes[] memory) {
        if(_getCommunityType() == 2) {
            require(member.isMember[msg.sender] == true, "Only clique members may view content from this clique");
        }
        return post.getAllPostIds();
    }

    function getAllPostCommentIds(bytes memory _postId) external view returns (bytes[] memory) {
        if(_getCommunityType() == 2) {
            require(member.isMember[msg.sender] == true, "Only clique members may view content from this clique");
        }
        return post.getAllCommentIds(_postId);
    }

    function getPostVotes(bytes memory _postId) external view returns (uint) {
        return post.getPostVotes(_postId);
    }

    function getCommentVotes(bytes memory _postId, bytes memory _commentId) external view returns (uint) {
        return post.getCommentVotes(_postId, _commentId);
    }

    function upvotePostId(bytes memory _postId, address _user) public {
        post.incPostVote(_postId);
        core.incUserRep(_user);
    }

    function downvotePostId(bytes memory _postId, address _user) external {
        post.decPostVote(_postId);
        core.decUserRep(_user);
    }

    function upvoteCommentId(bytes memory _postId, bytes memory _commentId, address _user) public {
        post.incCommentVote(_postId, _commentId);
        core.incUserRep(_user);
    }

    function downvotePostId(bytes memory _postId, bytes memory _commentId, address _user) external {
        post.decCommentVote(_postId, _commentId);
        core.decUserRep(_user);
    }

    function _getCommunityType() internal view returns (uint8) {
        uint8 commType = uint8(communityType);
        return commType;
    }

}