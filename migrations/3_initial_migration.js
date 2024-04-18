const ERC = artifacts.require("Token_Mint_Mod.sol");

module.exports = async function (deployer) {
  await deployer.deploy(
    ERC,
    'GAME',
    'GAME',
    "3000000000000000000000000",
    "0xf65E92F14a231E941cA61b27F82BB9773E5f6AcB"
  );
  const token = await ERC.deployed();
};
