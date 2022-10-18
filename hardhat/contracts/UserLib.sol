// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library UserLib {

    struct User {
        address[] userAddrs;
        mapping(address => uint) indexOfUser;
        mapping(address => bytes[]) userPostIds;
        mapping(address => mapping(bytes => uint)) indexOfPostId;

        mapping(address => bytes[]) userCommentIds;
        mapping(address => mapping(bytes => uint)) indexOfCommentId;
        mapping(address => uint) reputation;
    }
       
    function addUserPostId(User storage user, bytes memory _postId, address _user) public {
        user.indexOfPostId[_user][_postId] = user.userPostIds[_user].length;
        user.userPostIds[_user].push(_postId);
    }

    function getAllUserPostIds(User storage user, address _user) public view returns (bytes[] memory) {
        return user.userPostIds[_user];
    }

    function getUserRep(User storage user, address _user) public view returns (uint) {
        return user.reputation[_user];
    }

    function removeUserPostId(User storage user, bytes memory _postId, address _user) public {
        uint index = user.indexOfPostId[_user][_postId];
        uint lastIndex = user.userPostIds[_user].length - 1;
        bytes memory lastPostId = user.userPostIds[_user][lastIndex];

        user.indexOfPostId[_user][lastPostId] = index;
        delete user.indexOfPostId[_user][_postId];

        user.userPostIds[_user][index] = lastPostId;
        user.userPostIds[_user].pop();
    }

    function addUserCommentId(User storage user, bytes memory _commentId, address _user) public {
        user.indexOfCommentId[_user][_commentId] = user.userCommentIds[_user].length;
        user.userCommentIds[_user].push(_commentId);
    }

    function getAllUserCommentIds(User storage user, address _user) public view returns (bytes[] memory) {
        return user.userCommentIds[_user];
    }

    function removeUserCommentId(User storage user, bytes memory _commentId, address _user) public {
        uint index = user.indexOfCommentId[_user][_commentId];
        uint lastIndex = user.userCommentIds[_user].length - 1;
        bytes memory lastCommentId = user.userPostIds[_user][lastIndex];

        user.indexOfCommentId[_user][lastCommentId] = index;
        delete user.indexOfPostId[_user][_commentId];

        user.userPostIds[_user][index] = lastCommentId;
        user.userPostIds[_user].pop();
    }

    function incRep(User storage user, address _user) public {
        user.reputation[_user]++;
    }

    function decRep(User storage user, address _user) public {
        user.reputation[_user]--;
    }

}