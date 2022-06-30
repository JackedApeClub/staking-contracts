// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

interface IRewardToken is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract Stakeable is ERC721Holder {
    IRewardToken public rewardsToken;
    IERC721 public nft;

    uint256 public yieldsPaid;
    uint256 public rewardRate = 10; //17280; // seconds per token
    uint public stakedTotal;

    mapping(uint256 => address) public tokenOwner;
    mapping(address => Staker) internal stakers;

    struct Staker {
        uint256[] tokenIds;
        uint256[] stakedTimes;
        uint256 availableYield;
        uint256 lastUpdateTime;
    }

    event Staked(address indexed user, uint256 tokenId, uint256 timestamp);
    event Unstaked(address indexed user, uint256 tokenId, uint256 timestamp);
    event EmergencyUnstake(address indexed user, uint256 tokenId);

    constructor(IERC721 _nft, IRewardToken _rewardsToken) {
        nft = _nft;
        rewardsToken = _rewardsToken;
    }

    function getStakedTime(address _user)
        public
        view
        returns (uint256[] memory stakedTimes)
    {
        return stakers[_user].stakedTimes;
    }

    function getStakedTokenIds(address _user)
        public
        view
        returns (uint256[] memory tokenIds)
    {
        return stakers[_user].tokenIds;
    }

    function getYields(address _user)
        public
        view
        returns (uint256 availableYield)
    {
        return stakers[_user].availableYield;
    }

    modifier updateYields(address account) {
        
        Staker storage staker = stakers[account];
        uint nfts = staker.tokenIds.length;
        uint multiplier;
        
        if (nfts == 0){
            multiplier = 100;
            staker.lastUpdateTime = block.timestamp;
        } else if (nfts > 4) {
            multiplier = 200;
        } else if (nfts > 0) {
            multiplier = (75 + (25 * nfts));
        }

        staker.availableYield += ((multiplier * ((block.timestamp - staker.lastUpdateTime) * 1e18)) / 100) / rewardRate;
        staker.lastUpdateTime = block.timestamp;
        _;
    }

    function stake(uint256 tokenId) public updateYields(msg.sender) {
        _stake(msg.sender, tokenId);
    }

    function stakeBatch(uint256[] memory tokenIds) public updateYields(msg.sender) {
        for (uint i = 0; i < tokenIds.length; i++) {
            _stake(msg.sender, tokenIds[i]);
        }
    }

    function _stake(address _user, uint256 _tokenId) internal {
        require(
            nft.ownerOf(_tokenId) == _user,
            "user must be the owner of the token"
        );

        Staker storage staker = stakers[_user];

        staker.tokenIds.push(_tokenId);
        staker.stakedTimes.push(block.timestamp);
        tokenOwner[_tokenId] = _user;

        nft.safeTransferFrom(_user, address(this), _tokenId);
        emit Staked(_user, _tokenId, block.timestamp);
        stakedTotal++;
    }

    function unstake(uint256 _tokenId) public updateYields(msg.sender) {
        _unstake(msg.sender, _tokenId);
    }

    function unstakeBatch(uint256[] memory tokenIds) public updateYields(msg.sender) {
        //claimReward(msg.sender);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenOwner[tokenIds[i]] == msg.sender);
            _unstake(msg.sender, tokenIds[i]);
        }
    }

    function _unstake(address _user, uint256 _tokenId) internal {
        require(
            tokenOwner[_tokenId] == _user,
            "Nft Staking System: user must be the owner of the staked nft"
        );
        Staker storage staker = stakers[_user];
        
        // Needs to iterate to find the right index in the array
        if (staker.tokenIds.length > 0) {
            for (uint i = 0; i < staker.tokenIds.length; i++){
                if (staker.tokenIds[i] == _tokenId) {
                    staker.tokenIds[i] = staker.tokenIds[staker.tokenIds.length - 1];
                    staker.tokenIds.pop();
                    delete staker.stakedTimes[i];
                    break;
                }
            }
        }
        delete tokenOwner[_tokenId];

        nft.safeTransferFrom(address(this), _user, _tokenId);

        emit Unstaked(_user, _tokenId, block.timestamp);
        stakedTotal--;
    }

    // Unstake without caring about rewards. EMERGENCY ONLY.
    function emergencyUnstake(uint256 _tokenId) public {
        require(
            tokenOwner[_tokenId] == msg.sender,
            "nft._unstake: Sender must have staked tokenID"
        );
        _unstake(msg.sender, _tokenId);
        emit EmergencyUnstake(msg.sender, _tokenId);
    }

    function claimReward() public updateYields(msg.sender) {
        require(stakers[msg.sender].availableYield > 0 , "0 rewards yet");
        rewardsToken.mint(msg.sender, stakers[msg.sender].availableYield);
        stakers[msg.sender].availableYield = 0;
    }
}