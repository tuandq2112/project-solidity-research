// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**  
 * @dev  TokenA : BNB,ETH,USDT,...
 *       TokenB : IVIRSECoin 
 *
 * @dev  Staking is for user who want to get tokenB by lock their tokenA
 *       in this StakingBonus contract and receive tokenB after
 *       an amount of time 
 *
 * @dev  In this contract, there are 3 duration staking is 30,60,90 seconds and
 *       bonus rate between tokenA and tokenB described below :
 *       Duration 30 seconds - 1 tokenA bonus 1000 tokenB
 *       Duration 60 seconds - 1 tokenA bonus 2500 tokenB
 *       Duration 90 seconds - 1 tokenA bonus 5000 tokenB
 *       
 * @dev  In reality, different tokenB should have diffirent bonus rate with tokenA
*/

contract StakingBonus{
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    address public owner;
    uint public duration30 = 30;
    uint public duration60 = 60;
    uint public duration90 = 90;
    /**
     * @dev User address => staked amount of user
    */ 
    mapping(address => uint) private balanceStakeOf;
    /**
     * @dev User address => time end stake of user
    */ 
    mapping(address => uint) private timeEndStake;
     /**
     * @dev User address => duration stake
    */ 
    mapping(address => uint) private durationUser;

    constructor(address _tokenA,address _tokenB) {
        owner = msg.sender;
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    /**
     * @dev set stake of user = 0, time end stake of user = 0 and duration
     *      staking of user = 0
    */ 
    modifier resetStakeOfUser(){
        _;
        balanceStakeOf[msg.sender] = 0;
        timeEndStake[msg.sender] = 0;
        durationUser[msg.sender] = 0;
    }

    /**
     * @dev Require function must in staking state
    */ 
    modifier requireStaking(){
        require(timeEndStake[msg.sender] > 0, "didn't stake");
        _;
    }

    /**
     * @dev Stake duration 30 seconds
    */ 
    function stake30(uint _amount) external{ 
        require(timeEndStake[msg.sender] == 0, "already in stake");
        require(_amount > 0, "amount = 0");
        tokenA.transferFrom(msg.sender, address(this), _amount);
        balanceStakeOf[msg.sender] += _amount;
        timeEndStake[msg.sender] = block.timestamp + duration30;
        durationUser[msg.sender] = duration30;

    }

    /**
     * @dev Stake duration 60 seconds
    */ 
     function stake60(uint _amount) external{ 
        require(timeEndStake[msg.sender] == 0, "already in stake");
        require(_amount > 0, "amount = 0");
        tokenA.transferFrom(msg.sender, address(this), _amount);
        balanceStakeOf[msg.sender] += _amount;
        timeEndStake[msg.sender] = block.timestamp + duration60;
        durationUser[msg.sender] = duration60;
    }

    /**
     * @dev Stake duration 90 seconds
    */ 
     function stake90(uint _amount) external{ 
        require(timeEndStake[msg.sender] == 0, "already in stake");
        require(_amount > 0, "amount = 0");
        tokenA.transferFrom(msg.sender, address(this), _amount);
        balanceStakeOf[msg.sender] += _amount;
        timeEndStake[msg.sender] = block.timestamp + duration90;
        durationUser[msg.sender] = duration90;
    }

    /**
     * @dev Withdraw when duration of staking is over
     * @dev Get staking tokenA and bonus tokenB   
    */ 
    function withdrawFulltime() external requireStaking resetStakeOfUser{
        require(timeEndStake[msg.sender] < block.timestamp ,"haven't time yet");

        if(durationUser[msg.sender] == duration30){
            uint bonus = balanceStakeOf[msg.sender]*1000;
            require(tokenB.balanceOf(address(this)) >= bonus,"not enough balance");
            if(bonus > 0) {
                tokenA.transfer(msg.sender, balanceStakeOf[msg.sender]);
                tokenB.transfer(msg.sender, bonus);
            }
        }

        else if(durationUser[msg.sender] == duration60){
            uint bonus = balanceStakeOf[msg.sender]*2500;
            require(tokenB.balanceOf(address(this)) >= bonus,"not enough balance");
            if(bonus > 0) {
                tokenA.transfer(msg.sender, balanceStakeOf[msg.sender]);
                tokenB.transfer(msg.sender, bonus);
            }
        }

        else if(durationUser[msg.sender] == duration90){
            uint bonus = balanceStakeOf[msg.sender]*5000;
            require(tokenB.balanceOf(address(this)) >= bonus,"not enough balance");
            if(bonus > 0) {
                tokenA.transfer(msg.sender, balanceStakeOf[msg.sender]);
                tokenB.transfer(msg.sender, bonus);
            }
        }
    }

     /**
     * @dev Get time left to earn reward of `_account`
    */ 
    function viewTimeUntilWithDrawFullTime(address _account) view external returns(uint){ 
        return timeEndStake[_account] - block.timestamp;
    }
 
    /**
     * @dev User force withdraw when the time had not yet come
     * @dev When force withdraw, user don't get any bonus, just get staking token 
    */ 
    function forceWithdraw() external requireStaking resetStakeOfUser{
        require(timeEndStake[msg.sender] > block.timestamp ,"go to withdrawFullTime");
        tokenA.transfer(msg.sender, balanceStakeOf[msg.sender]);
    }

    /**
     * @dev Get time end stake of `_account`
    */ 
    function getTimeEndStake(address _account) external view returns(uint){
        return timeEndStake[_account];
    }

    /**
     * @dev Get time end stake of `_account`
    */ 
    function getBonusWillGet(address _account) external view returns(uint bonus){
        if(durationUser[_account] == duration30){
            bonus = balanceStakeOf[_account]*1000;
            return bonus;
        }

        else if(durationUser[_account] == duration60){
            bonus = balanceStakeOf[_account]*2500;
            return bonus;
        }

        else if(durationUser[_account] == duration90){
            bonus = balanceStakeOf[_account]*5000;
            return bonus;
        }
    }

    /**
     * @dev Get balance stake of `_account`
    */ 
    function getBalanceStakeOf(address _account) external view returns(uint){
        return balanceStakeOf[_account];
    }
}
