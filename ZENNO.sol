// SPDX-License-Identifier:MIT 
// **disclaimer from contract deployer and development team**
// **use of this code, project, and commodity token is permitted as long as the user agrees to the following**
// *We are not responsible for any negative use/misuse, any Profit/Losses, of this project or its commodity token of/by its users.** 
//0x035E552667813C322e397A2633199F1050e2BaFb blacklisted wallet test
//0x51aeaF0EaF0919da5bf5865aC6a0F4D270De060f test contract
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20, ERC20Burnable, ERC20Pausable, AccessControl, ERC20Permit {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public maxClaimsPerDay;
    uint256 public holdersClaimAmount;
    uint256 public requiredTokenBalance;
    uint256 public freeTokenAmount;
    uint256 public promoAmount;
    mapping(address => uint256) public lastClaimed;
    mapping(address => uint256) public lastPromoClaim;
    mapping(address => uint256) public lastFreeClaim;
    mapping(address => uint256) public tokenBalances;
    mapping(address => bool) public isBlacklisted;
    modifier notBlacklisted() { require(!isBlacklisted[msg.sender],
     "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse/Abuse; And Is No Longer Able To Use Use Our Contract"); _; }
    event WhaleTransfer (address indexed from, address indexed to, uint256 amount); 
    event SharkTransfer (address indexed from, address indexed to, uint256 amount); 
    event TadpolTransfer (address indexed from, address indexed to, uint256 amount); 


    constructor(address defaultAdmin, address pauser, address minter)
        ERC20("ZEN-OH", "ZENOH")
        ERC20Permit("ZEN-OH")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _mint(msg.sender, 420000000 * 10 ** decimals());
        _grantRole(MINTER_ROLE, minter);
        
        maxClaimsPerDay = 10000;//set default token claims per day to 10,000
        holdersClaimAmount= 2500 * 10 ** decimals();//set token default holder claim rate to 2500.0 per claim(enter new in solidity)
        requiredTokenBalance = 1000000 * 10 ** decimals(); // set default required token balance for claiming 1,000,000 Tokens(enter new in solidity)
        freeTokenAmount = 100 * 10 ** decimals(); // set default free token amount to 100 per claim(enter new in solidity)
        promoAmount = 10 * 10 ** decimals();// set default promo amount to 20 tokens per claim
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function promoClaim() public{require(lastPromoClaim[msg.sender] + 20 minutes <= block.timestamp,
    "please wait 20 minutes before claiming again");
    require(promoAmount > 0, 
    "We're Sorry; Promo Token Claims Were Only Available For A Limited Time And Have Now Since Been Discontinued.");
    require(!isBlacklisted[msg.sender], "Your Wallet Has Been Blacklisted For Project Misuse/Abuse; And Is No Longer Able To Use Our Claim Features");

    _mint(msg.sender, promoAmount);lastPromoClaim[msg.sender] = block.timestamp; maxClaimsPerDay--;
    } 

     function freeClaim() public{require(lastFreeClaim[msg.sender] + 1 days <= block.timestamp,
    "You have reached the daily claim limit; Only 1 free claim per user every 24 hours.");
    require(freeTokenAmount > 0, "We're Sorry; Free Token Claims Are Temporarily Suspended. Please Try Again Later.");
    require(maxClaimsPerDay > 0, "The current max amount of claims has been exceeded.");
    require(!isBlacklisted[msg.sender], "Your Wallet Has Been Blacklisted For Project Misuse/Abuse; And Is No Longer Able To Use Our Claim Features");

    _mint(msg.sender, freeTokenAmount);lastFreeClaim[msg.sender] = block.timestamp; maxClaimsPerDay--;
    } 

    function holdersClaim() public{require(lastClaimed[msg.sender] + 7 days <= block.timestamp,
    "You have reached the daily claim limit; Only 1 claim per holder every 7 days");
    require( balanceOf(msg.sender) >= requiredTokenBalance, "You do not have the required token balance to claim." );
    require(holdersClaimAmount > 0, "We're Sorry; Token Claims Are Temporarily Suspended. Please Try Again Later.");
    require(!isBlacklisted[msg.sender], "Your Wallet Has Been Blacklisted For Project Misuse/Abuse; And Is No Longer Able To Use Our Claim Features");
    
    
    _mint(msg.sender, holdersClaimAmount);lastClaimed[msg.sender] = block.timestamp;
    }

      function setMaxClaimsPerDay(uint256 _maxClaimsPerDay) public onlyRole(DEFAULT_ADMIN_ROLE){
        maxClaimsPerDay = _maxClaimsPerDay;
     }
     
     function setHoldersClaimAmount(uint256 _holdersClaimAmount) public onlyRole(DEFAULT_ADMIN_ROLE){
        holdersClaimAmount = _holdersClaimAmount;
     }

    function setRequiredTokenBalance(uint256 _requiredTokenBalance) public onlyRole(DEFAULT_ADMIN_ROLE){
        requiredTokenBalance = _requiredTokenBalance;
    }

    function setFreeTokenAmount(uint256 _freeTokenAmount) public onlyRole(DEFAULT_ADMIN_ROLE){
        freeTokenAmount = _freeTokenAmount;
     }

     function setPromoAmount(uint256 _promoAmount) public onlyRole(DEFAULT_ADMIN_ROLE){
        promoAmount = _promoAmount;
        }

    
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function blacklistAddress (address _targetAddress) public onlyRole(PAUSER_ROLE){isBlacklisted[_targetAddress] = true;
    }

    function removeBlacklistAddress (address _targetAddress) public onlyRole(PAUSER_ROLE){isBlacklisted[_targetAddress] = false;
    }

   function transfer(address recipient, uint256 amount) public notBlacklisted override returns (bool){require(!isBlacklisted[msg.sender],
     "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse And Is No Longer Able To Use Use Our Contract");
    require(!isBlacklisted[recipient],
     "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse And Is No Longer Able To Use Use Our Contract");
    
    if (amount >= 1000000 * 10 ** decimals()){
      emit WhaleTransfer(msg.sender, recipient, amount); 
    }
    else if (amount >= 500000 *10 ** decimals() && amount<= 999999 * 10 **decimals()){
        emit SharkTransfer(msg.sender, recipient, amount);
      }

      else if (amount >= 250000 *10 ** decimals() && amount<= 499999 * 10 **decimals()){
        emit TadpolTransfer(msg.sender, recipient, amount);
      }
    return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public notBlacklisted override returns (bool){
      require(!isBlacklisted[sender],
       "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse And Is No Longer Able To Use Use Our Contract");
      require(!isBlacklisted[recipient], 
      "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse And Is No Longer Able To Use Use Our Contract");
      
      if (amount >= 1000000 * 10 ** decimals()){
      emit WhaleTransfer(sender, recipient, amount); }
      else if (amount >= 500000 *10 ** decimals() && amount<= 999999 * 10 **decimals()){
        emit SharkTransfer(sender, recipient, amount);
      }
       else if (amount >= 250000 *10 ** decimals() && amount<= 499999 * 10 **decimals()){
        emit TadpolTransfer(sender, recipient, amount);
      }
      return super.transferFrom(sender,recipient, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }


}
