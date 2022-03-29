async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deployer Address: " + deployer.address)
    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());
    
    const Token = await ethers.getContractFactory("MissingTooth");

    const token = await Token.deploy(
    '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', 
    '0x70997970C51812dc3A010C7d01b50e0d17dc79C8', 
    '0xf5e3D593FC734b267b313240A0FcE8E0edEBD69a',
    'https://public-pre-ipfs.s3.amazonaws.com/MissingToothNFT/images/',
    'https://public-pre-ipfs.s3.amazonaws.com/MissingToothNFT/assets/reveal.json');

    console.log("Token address:", token.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });