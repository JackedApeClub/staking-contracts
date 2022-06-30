var PumpToken = artifacts.require("PumpTokenERC20");
var JackedApes = artifacts.require("JackedApeClub");
var Staking = artifacts.require("Stakeable");


var _name = "JackedApeClub"
var _symbol = "JAC"
var _initBaseURI = "ipfs://QmcUVA5X5zbzaSLU9qDTSzKtQPZKPKNncCGCvSjJgQpqs4/"
var _initNotRevealedUri = "ipfs://QmcnAmP27xac3WQrcrVjXu91dcLa436bLU5Z4oUVS3DKNs/hidden.json"

module.exports = async function(deployer) {
  await deployer.deploy(JackedApes, _name, _symbol, _initBaseURI, _initNotRevealedUri);
  const nft = await JackedApes.deployed();

  await deployer.deploy(PumpToken);
  const token = await PumpToken.deployed(); 

  await deployer.deploy(Staking, nft.address, token.address);
  const stakingAddress = await Staking.deployed();
};