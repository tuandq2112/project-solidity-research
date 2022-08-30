// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "./Token.sol";

/**  
 * @dev  TokenA : BNB,ETH,USDT,...
 *       TokenB : IVIRSECoin 
 *
 * @dev  Staking is for user who want to get tokenB by lock their tokenA
 *       in this StakingBonus contract and receive tokenB after
 *       an amount of time 
 *
 * @dev  Maximum tokenA each user can stake in one period staking is 50 token
 *
 * @dev  In this contract, for testing, there are 3 duration staking is 30,60,90
 *       seconds and bonus rate between tokenA and tokenB described below :
 *
 *       +) If there are less than or equal to 1 people in staking pool 
 *              Duration 30 seconds - 1 tokenA bonus 1000 tokenB
 *              Duration 60 seconds - 1 tokenA bonus 2500 tokenB
 *              Duration 90 seconds - 1 tokenA bonus 5000 tokenB
 *       +) If there are less than or equal to 2 people in staking pool 
 *              Duration 30 seconds - 1 tokenA bonus 100 tokenB
 *              Duration 60 seconds - 1 tokenA bonus 250 tokenB
 *              Duration 90 seconds - 1 tokenA bonus 500 tokenB   
 *       +) If there are more than 2 people in staking pool 
 *           => Staking pool is full, can't stake
 *
 *
 * @dev  In reality, different tokenB should have diffirent bonus rate with tokenA
 *
 * 
*/

contract StakingBonus{
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    address public owner;
    uint public duration30 = 30;
    uint public duration60 = 60;
    uint public duration90 = 90;
    uint public maximumTokenStaking = 50;
     /**
     * @dev Number of user in staking pool
    */ 
    uint public numberUserStaking = 0;
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
     /**
     * @dev User address => NumberPersonStakingToPerson
    */ 
    mapping(address => uint) private numberUserStakingToUser;

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
     * @dev Require of stake funtion
    */ 
    modifier requireStartStaking(uint _amount){
        require(timeEndStake[msg.sender] == 0, "already in stake");
        require(_amount > 0, "amount = 0");
        require(_amount < maximumTokenStaking, "maximum amount staking should less than or equal to 50 token");
        require(numberUserStaking < 2,"staking pool is full");
        _;
    }

    /**
     * @dev Handle number user in staking pool
    */ 
    modifier handleNumberUser(){
        _;
        numberUserStaking++;
        numberUserStakingToUser[msg.sender] = numberUserStaking;
    }

    /**
     * @dev Stake duration 30 seconds
    */ 
    function stake30(uint _amount) requireStartStaking(_amount) handleNumberUser external{ 
        tokenA.transferFrom(msg.sender, address(this), _amount);
        balanceStakeOf[msg.sender] += _amount;
        timeEndStake[msg.sender] = block.timestamp + duration30;
        durationUser[msg.sender] = duration30;
    }

    /**
     * @dev Stake duration 60 seconds
    */ 
    function stake60(uint _amount) requireStartStaking(_amount) handleNumberUser external{ 
        tokenA.transferFrom(msg.sender, address(this), _amount);
        balanceStakeOf[msg.sender] += _amount;
        timeEndStake[msg.sender] = block.timestamp + duration60;
        durationUser[msg.sender] = duration60;
    }

    /**
     * @dev Stake duration 90 seconds
    */ 
    function stake90(uint _amount) requireStartStaking(_amount) handleNumberUser external{ 
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
        uint bonus;
        if(durationUser[msg.sender] == duration30){
            numberUserStakingToUser[msg.sender] <= 1 ?
            bonus = balanceStakeOf[msg.sender]*1000 :
            bonus = balanceStakeOf[msg.sender]*100;       
            require(tokenB.balanceOf(address(this)) >= bonus,"not enough balance");
            if(bonus > 0) {
                tokenA.transfer(msg.sender, balanceStakeOf[msg.sender]);
                tokenB.transfer(msg.sender, bonus);
            }
        }

        else if(durationUser[msg.sender] == duration60){
            numberUserStakingToUser[msg.sender] <= 1 ?
            bonus = balanceStakeOf[msg.sender]*2500 :
            bonus = balanceStakeOf[msg.sender]*250; 
            require(tokenB.balanceOf(address(this)) >= bonus,"not enough balance");
            if(bonus > 0) {
                tokenA.transfer(msg.sender, balanceStakeOf[msg.sender]);
                tokenB.transfer(msg.sender, bonus);
            }
        }

        else if(durationUser[msg.sender] == duration90){
            numberUserStakingToUser[msg.sender] <= 1 ?
            bonus = balanceStakeOf[msg.sender]*5000 :
            bonus = balanceStakeOf[msg.sender]*500; 
            require(tokenB.balanceOf(address(this)) >= bonus,"not enough balance");
            if(bonus > 0) {
                tokenA.transfer(msg.sender, balanceStakeOf[msg.sender]);
                tokenB.transfer(msg.sender, bonus);
            }
        }
        numberUserStaking--;
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
        numberUserStaking--;
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
            numberUserStakingToUser[msg.sender] <= 1 ? 
            bonus = balanceStakeOf[_account]*1000 :   
            bonus = balanceStakeOf[_account]*100;
        }

        else if(durationUser[_account] == duration60){
            numberUserStakingToUser[msg.sender] <= 1 ? 
            bonus = balanceStakeOf[_account]*2500 :   
            bonus = balanceStakeOf[_account]*250;
        }

        else if(durationUser[_account] == duration90){
            numberUserStakingToUser[msg.sender] <= 1 ? 
            bonus = balanceStakeOf[_account]*5000 :   
            bonus = balanceStakeOf[_account]*500;
        }
        return bonus;
    }

    /**
     * @dev Get balance stake of `_account`
    */ 
    function getBalanceStakeOf(address _account) external view returns(uint){
        return balanceStakeOf[_account];
    }
}
