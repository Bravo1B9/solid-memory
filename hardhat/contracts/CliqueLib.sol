// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { Clique } from "./Clique.sol";

library CliqueLib {

    struct CliqueStruct {
        Clique[] cliques;
        mapping(Clique => uint) indexOfClique;
    }

    function addClique(CliqueStruct storage clique, Clique _clique) public {
        clique.indexOfClique[_clique] = clique.cliques.length;
        clique.cliques.push(_clique);
    }

    function getAllCliques(CliqueStruct storage clique) public view returns (Clique[] memory) {
        return clique.cliques;
    }

}