pragma solidity =0.6.12;

import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Pair.sol';
import './UniswapV2Pair.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract UniswapV2Factory is IUniswapV2Factory {
    address public override migrator;
    address public override feeToSetter;

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;
    mapping(address => CfxAddressInfo) public allCfxEthAddrs;

    struct CfxAddressInfo {
      address tokenAddr;
      address ethAddr;
    }

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor() public {
        feeToSetter = msg.sender;
    }

    function allPairsLength() external override view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IUniswapV2Pair(pair).initialize(token0, token1);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setMigrator(address _migrator) external override {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        migrator = _migrator;
    }

    function addCfxEthAddr(address pair, address cfxTokenAddr, address cfxEthAddr) external override {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        allCfxEthAddrs[pair] = CfxAddressInfo({
            tokenAddr: cfxTokenAddr,
            ethAddr: cfxEthAddr
        });
    }

    function getCfxEthAddrs(address pair) external override view returns (address cfxTokenAddr, address cfxEthAddr) {
        CfxAddressInfo memory _info = allCfxEthAddrs[pair];

        return (_info.tokenAddr, _info.ethAddr);
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }


}
