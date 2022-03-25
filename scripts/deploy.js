async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer Address: " + deployer.address)
    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());
    
    const Token = await ethers.getContractFactory("ToothyTooths");

    const token = await Token.deploy(
    '0xf5e3D593FC734b267b313240A0FcE8E0edEBD69a',
    'https://techoshiprojects.s3.amazonaws.com/MonstersCommunity/json/',
    'https://techoshiprojects.s3.amazonaws.com/MonstersCommunity/assets/reveal.json');

    console.log("Token address:", token.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });