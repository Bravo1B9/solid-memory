const hre = require("hardhat");

async function main() {

  const UserLib = await hre.ethers.getContractFactory("UserLib");
  const userLib = await UserLib.deploy();
  await userLib.deployed();

  const CliqueLib = await hre.ethers.getContractFactory("CliqueLib");
  const cliqueLib = await CliqueLib.deploy();
  await cliqueLib.deployed();

  const CliqueMemberLib = await hre.ethers.getContractFactory("CliqueMemberLib");
  const cliqueMemberLib = await CliqueMemberLib.deploy();
  await cliqueMemberLib.deployed();

  const CliquePubsLib = await hre.ethers.getContractFactory("CliquePubsLib");
  const cliquePubsLib = await CliquePubsLib.deploy();
  await cliquePubsLib.deployed();

  const Core = await hre.ethers.getContractFactory("Core", {
    libraries: {
      UserLib: userLib.address,
      CliqueLib: cliqueLib.address,
      CliqueMemberLib: cliqueMemberLib.address,
      CliquePubsLib: cliquePubsLib.address
    },
  });
  const core = await Core.deploy();

  await core.deployed();

  console.log(
    `Core deployed to: ${core.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});