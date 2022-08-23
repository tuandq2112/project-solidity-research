// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**  
 * @dev  Staking is for user who want to get token by lock their token
 *       in this StakingRewards contract and receive bonus token after
 *       an amount of time 
 * @dev  In this contract, duration staking is 30 seconds and
 *       bonus reward is 10%
*/

contract StakingRewards{
    IERC20 public immutable token;
    address public owner;
    uint public duration = 30;
    /**
     * @dev User address => staked amount of user
    */ 
    mapping(address => uint) private balanceStakeOf;
    /**
     * @dev User address => time end stake of user
    */ 
    mapping(address => uint) private timeEndStake;

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }
    /**
     * @dev set stake of user = 0 and time end stake of user = 0 
    */ 
    modifier resetStakeOfUser(){
        _;
        balanceStakeOf[msg.sender] = 0;
        timeEndStake[msg.sender] = 0;
    }

    /**
     * @dev Require function must in staking state
    */ 
    modifier requireStaking(){
        require(timeEndStake[msg.sender] > 0, "didn't stake");
        _;
    }

    /**
     * @dev Stake action
    */ 
    function stake(uint _amount) external{ 
        require(timeEndStake[msg.sender] == 0, "already in stake");
        require(_amount > 0, "amount = 0");
        token.transferFrom(msg.sender, address(this), _amount);
        balanceStakeOf[msg.sender] += _amount;
        timeEndStake[msg.sender] = block.timestamp + duration;
    }

    /**
     * @dev Withdraw when duration of staking is over
     * @dev Get staking token and reward equal 10% of staking token 
    */ 
    function withdrawFulltime() external requireStaking resetStakeOfUser{
        require(timeEndStake[msg.sender] < block.timestamp ,"haven't time yet");
        uint reward = balanceStakeOf[msg.sender] * 110 / 100; // bonus reward = 10%
        require(token.balanceOf(address(this)) > reward,"not enough balance");
        if(reward > 0) {
            token.transfer(msg.sender, reward);
        }
    }

     /**
     * @dev Get time left to earn reward of user
    */ 
    function viewTimeUntilWithDrawFullTime() view external requireStaking returns(uint){ 
        require(timeEndStake[msg.sender] > block.timestamp ,"go to withdrawFullTime");
        return (timeEndStake[msg.sender] - block.timestamp);
    }
 
    /**
     * @dev User force withdraw when the time had not yet come
     * @dev When force withdraw, user don't get any reward, just get staking token 
    */ 
    function forceWithdraw() external requireStaking resetStakeOfUser{
        require(timeEndStake[msg.sender] > block.timestamp ,"go to withdrawFullTime");
        token.transfer(msg.sender, balanceStakeOf[msg.sender]);
    }

    /**
     * @dev Get time end stake of `_account`
    */ 
    function getTimeEndStake(address _account) external view returns(uint){
        return timeEndStake[_account];
    }

    /**
     * @dev Get balance stake of `_account`
    */ 
    function getBalanceStakeOf(address _account) external view returns(uint){
        return balanceStakeOf[_account];
    }
}
