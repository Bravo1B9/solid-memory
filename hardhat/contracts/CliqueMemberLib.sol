// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library CliqueMemberLib {

    struct CliqueMember {
        address[] members;
        mapping(address => uint) indexOf;
        mapping(address => bool) isMember;
    }

    function add(CliqueMember storage cliqueMember, address _member) public {
        require(!cliqueMember.isMember[_member], "Address is already a member of this Clique");
        cliqueMember.isMember[_member] = true;
        cliqueMember.indexOf[_member] = cliqueMember.members.length;
        cliqueMember.members.push(_member);
    }

    function getAddressByIndex(CliqueMember storage cliqueMember, uint _index) public view returns(address) {
        return cliqueMember.members[_index];
    }

    function getStatus(CliqueMember storage cliqueMember, address _member) public view returns (bool) {
        return cliqueMember.isMember[_member];
    }

    function getIndexByAddress(CliqueMember storage cliqueMember, address _member) public view returns (uint) {
        return cliqueMember.indexOf[_member];
    }

    function getAll(CliqueMember storage cliqueMember) public view returns(address[] memory) {
        return cliqueMember.members;
    }

    function getNum(CliqueMember storage cliqueMember) public view returns(uint) {
        return cliqueMember.members.length;
    }

    function remove(CliqueMember storage cliqueMember, address _member) public {
        require(cliqueMember.isMember[_member], "Address is not a member");
        delete cliqueMember.isMember[_member];

        uint index = cliqueMember.indexOf[_member];
        uint lastIndex = cliqueMember.members.length - 1;
        address lastMember = cliqueMember.members[lastIndex];

        cliqueMember.indexOf[lastMember] = index;
        delete cliqueMember.indexOf[_member];

        cliqueMember.members[index] = lastMember;
        cliqueMember.members.pop();
    }

}