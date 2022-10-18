// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library CliquePubsLib {

    struct Post {
        bytes[] postIds;
        mapping (bytes => bool) postExists;
        mapping (bytes => mapping (bytes => bool)) commentExists;
        mapping (bytes => uint) postVotes;
        mapping (bytes => mapping (address => bool)) hasVotedPost;
        mapping (bytes => mapping (bytes => mapping (address => bool))) hasVotedComment;
        mapping (bytes => mapping (bytes => uint)) commentVotes;
        mapping (bytes => uint) indexOfPostId;
        mapping (bytes => mapping (bytes => uint)) indexOfCommentId;
        mapping (bytes => bytes[]) commentIds;
        mapping (address => bytes[]) creatorPostIds;
        mapping (address => bytes[]) creatorCommentIds;
        mapping (bytes => address) postCreator;
        mapping (bytes => mapping (bytes => address)) commentCreator;
    }

    function addPostId(Post storage post, bytes memory _postId) internal {
        require(post.postExists[_postId] == false, "Post ID already exists");
        post.indexOfPostId[_postId] = post.postIds.length;
        post.creatorPostIds[msg.sender].push(_postId);
        post.postCreator[_postId] = msg.sender;
        post.postExists[_postId] = true;
        post.postIds.push(_postId);
    }

    function addCommentId(Post storage post, bytes memory _postId, bytes memory _commentId) internal {
        require(post.commentExists[_postId][_commentId] == false, "Comment ID already exists");
        post.creatorCommentIds[msg.sender].push(_commentId);
        post.indexOfCommentId[_postId][_commentId] = post.commentIds[_postId].length;
        post.commentCreator[_postId][_commentId] = msg.sender;
        post.commentExists[_postId][_commentId] = true;
        post.commentIds[_postId].push(_commentId);
    }

    function incPostVote(Post storage post, bytes memory _postId) public {
        require(post.hasVotedPost[_postId][msg.sender] == false, "Caller has already voted on this post ID");
        post.hasVotedPost[_postId][msg.sender] = true;
        post.postVotes[_postId]++;
    }

    function decPostVote(Post storage post, bytes memory _postId) public {
        require(post.hasVotedPost[_postId][msg.sender] == false, "Caller has already voted on this post ID");
        post.hasVotedPost[_postId][msg.sender] = true;
        post.postVotes[_postId]--;
    }

    function incCommentVote(Post storage post, bytes memory _postId, bytes memory _commentId) public {
        require(post.hasVotedComment[_postId][_commentId][msg.sender] == false, "Caller has already voted on this comment ID");
        post.hasVotedComment[_postId][_commentId][msg.sender] = true;
        post.commentVotes[_postId][_commentId]++;
    }

    function decCommentVote(Post storage post, bytes memory _postId, bytes memory _commentId) public {
        require(post.hasVotedComment[_postId][_commentId][msg.sender] == false, "Caller has already voted on this comment ID");
        post.hasVotedComment[_postId][_commentId][msg.sender] = true;
        post.commentVotes[_postId][_commentId]--;
    }

    function getPostId(Post storage post, uint _index) internal view returns (bytes memory) {
        return post.postIds[_index];
    }

    function getAllPostIds(Post storage post) internal view returns (bytes[] memory) {
        return post.postIds;
    }

    function getCommentId(Post storage post, bytes memory _postId, uint _index) internal view returns (bytes memory) {
        return post.commentIds[_postId][_index];
    }

    function getAllCommentIds(Post storage post, bytes memory _postId) internal view returns (bytes[] memory) {
        return post.commentIds[_postId];
    }

    function getAllCreatorPostIds(Post storage post, address _creator) internal view returns (bytes[] memory) {
        return post.creatorPostIds[_creator];
    }

    function getAllCreatorCommentIds(Post storage post, address _creator) internal view returns (bytes[] memory) {
        return post.creatorCommentIds[_creator];
    }

    function getPostVotes(Post storage post, bytes memory _postId) internal view returns (uint) {
        return post.postVotes[_postId];
    }

    function getCommentVotes(Post storage post, bytes memory _postId, bytes memory _commentId) internal view returns (uint) {
        return post.commentVotes[_postId][_commentId];
    }

    function getPostCreator(Post storage post, bytes memory _postId) internal view returns (address) {
        return post.postCreator[_postId];
    }

    function getCommentCreator(Post storage post, bytes memory _postId, bytes memory _commentId) internal view returns (address) {
        return post.commentCreator[_postId][_commentId];
    }

    function removePost(Post storage post, bytes memory _postId) internal {
        delete post.commentIds[_postId];
        delete post.postExists[_postId];

        uint index = post.indexOfPostId[_postId];
        uint lastIndex = post.postIds.length - 1;
        bytes memory lastPostId = post.postIds[lastIndex];

        post.indexOfPostId[lastPostId] = index;
        delete post.indexOfPostId[_postId];

        post.postIds[index] = lastPostId;
        post.postIds.pop();
    }

    function removeComment(Post storage post, bytes memory _postId, bytes memory _commentId) public {
        delete post.commentExists[_postId][_commentId];

        uint index = post.indexOfCommentId[_postId][_commentId];
        uint lastIndex = post.commentIds[_postId].length - 1;
        bytes memory lastCommentId = post.commentIds[_postId][lastIndex];

        post.indexOfCommentId[_postId][lastCommentId] = index;
        delete post.indexOfCommentId[_postId][_commentId];

        post.commentIds[_postId][index] = lastCommentId;
        post.commentIds[_postId].pop();
    }

}