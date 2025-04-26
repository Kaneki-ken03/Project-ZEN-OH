// SPDX-License-Identifier: NONE 
// **disclaimer from contract deployer and development team**
// **use of this code, project, and commodity token is permitted as long as the user agrees to the following**
// *We are not responsible for any negative use/misuse, any Profit/Losses, of this project or its commodity token of/by its users.** 
//** we reserve the right to invoke an up to 5% burn and up to 5% charity fee on token transfers.**
pragma solidity ^0.8.26; 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";   
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
// Interface for the NFT contract 
interface INFT { function balanceOf(address owner) external view returns (uint256); 
} 
contract test is ERC20, ERC20Burnable, ERC20Pausable, AccessControl, ERC20Permit {
     bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE"); 
     bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); 
     address public charityAddress;// Dev Charity Wallet; Creator/Platform Transaction Fee.
     uint256 public whitelistTokenAmount;//amount of tokens to be claimed once per whitelisted address
     uint256 public stakingTokenBalance;//minimum balance required for liquid staking.
     uint256 public claimAmount;//new user claim amount
     uint256 public maxClaims;// max amount of claims for new users (set to 200,000)
     uint256 public whitelistClaims;//max amount of claims for whitelisted users (set to 100)
     uint256 public stakingPercent;// staking rate percent 100=1%, 50=0.5%, etc.
     uint256 public burnPercent;// transfer fee percent 100=1%, 50=0.5%, etc.
     uint256 public charityPercent;// transfer fee percent 100=1%, 50=0.5%, etc.
     uint256 public holdersClaimAmount;// nft holder claim amount 10 tokens per nft 
     mapping (address => uint256) public lastStakingClaim;  
     mapping(address => uint256) public tokenBalances; 
     mapping(address => bool) public isBlacklisted; 
     mapping(address => bool) public isWhitelisted;
     mapping (address => bool) public hasClaimed;
     mapping (address => bool) public Claimed;
     mapping (address => uint256) public lastClaimed;
     modifier notBlacklisted() { require(!isBlacklisted[msg.sender], 
     "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse/Abuse; And Is No Longer Able To Use Our Contract"); _; 
     }
     modifier onlyWhitelisted(){require (isWhitelisted[msg.sender],
     "your address is not whitelisted and is not eligible to claim this function");_;
     }
      event WhaleTransfer(address indexed from, address indexed to, uint256 amount); 
      event SharkTransfer(address indexed from, address indexed to, uint256 amount); 
      event TadpolTransfer(address indexed from, address indexed to, uint256 amount); 
       INFT public nftContract; // NFT contract address
      constructor(address defaultAdmin, address pauser, address minter, address _charityAddress, address _nftContract) 
      ERC20("TEST22", "TEST22")
      ERC20Permit("TEST22") {
         _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin); 
         _grantRole(PAUSER_ROLE, pauser); 
         _mint(msg.sender, 350000000 * 10 ** decimals());
         //initial supply is intended to be a total of 420,000,000 tokens; breakdown is as follows.
         //mints initial supply to deployers wallet 350 million tokens (50,000,000 dev team allotment; 300,000,000 liquidity pool.) 
         //up to 50,000,000 will be minted by up to 100 whitelisted users and up to 20,000,000 will be minted by up to 200,000 new users. (350,000,000 + 50,000,000 + 20,000,000)
          _grantRole(MINTER_ROLE, minter);
          whitelistTokenAmount = 500000 * 10 ** decimals(); // token amount to be claaimed once by whitelisted wallet addresses. 
          charityAddress = _charityAddress; // recieves platform/transfer fee set by dev.
          stakingTokenBalance = 100 * 10 ** decimals();// minimum of 100 tokens required for liquid staking.
          claimAmount = 100 * 10 ** decimals();//new user claim amount
          maxClaims = 200000;// max amount of claims for new users (set to 200,000)
          stakingPercent = 100;// staking rate percent 100=1%, 50=0.5%, etc.
          charityPercent = 250;// transfer fee percent 100=1%, 50=0.5%, etc.
          burnPercent = 250;// transfer fee percent 100=1%, 50=0.5%, etc.
          whitelistClaims = 100;//max amount of claims for whitelisted users (set to 100)
          nftContract = INFT(_nftContract); // Set the NFT contract address 
          holdersClaimAmount = 10 * 10 ** decimals();// nft holder claim amount 10 tokens per nft 
          } 
          function pause() public onlyRole(PAUSER_ROLE) { _pause(); 
          } 
          function unpause() public onlyRole(PAUSER_ROLE) { _unpause(); 
          } 
          function newUserClaim() public { 
            require(!Claimed[msg.sender], 
            "You have reached the max claim limit; Only 1 claim per new user."); 
            require(maxClaims > 0, "We're Sorry; the max amount of new user claims has been exceded.");  
            _mint(msg.sender, claimAmount); Claimed[msg.sender] = true; maxClaims --;
            } 
          function whitelistClaim() public onlyWhitelisted { 
            require(!hasClaimed[msg.sender], 
            "You have reached the max claim limit; Only 1 free claim per whitelisted user."); 
            require(whitelistClaims > 0, "We're Sorry; the max amount of whitelist claims has been exceded.");
            require(whitelistTokenAmount > 0, "We're Sorry; whitelist Token Claims Are Temporarily Suspended. Please Try Again Later.");  
            _mint(msg.sender, whitelistTokenAmount); hasClaimed[msg.sender] = true; whitelistClaims--;
            } 
            
                function liquidStakingClaim() public { 
                uint256 balanceOf = balanceOf(msg.sender); // Get token balance 
                require(lastStakingClaim[msg.sender] + 30 days <= block.timestamp, 
                "You have reached the claim limit; please try again later"); 
                require(balanceOf >= stakingTokenBalance, "You do not have the required token balance for liquid staking.");  
                require(!isBlacklisted[msg.sender], 
                "Your Wallet Has Been Blacklisted For Project Misuse/Abuse; And Is No Longer Able To Use Our Claim Features");
                uint256 stakeRate = balanceOf * stakingPercent/10000;   
                    _mint(msg.sender, stakeRate);lastStakingClaim[msg.sender] = block.timestamp;
                    }

                    function nftHoldersClaim() public { 
                uint256 nftAmount = nftContract.balanceOf(msg.sender); // Get NFT balance 
                require(lastClaimed[msg.sender] + 30 days <= block.timestamp, 
                "You have reached the claim limit; lease try again later"); 
                require(nftContract.balanceOf(msg.sender) >= 1, "You do not have the minimum NFT balance to claim."); 
                require(holdersClaimAmount > 0, "We're Sorry; NFT Claims Are Temporarily Suspended. Please Try Again Later."); 
                require(!isBlacklisted[msg.sender], 
                "Your Wallet Has Been Blacklisted For Project Misuse/Abuse; And Is No Longer Able To Use Our Claim Features"); 
                
                  uint256 totalAmount= holdersClaimAmount * nftAmount; 
                    _mint(msg.sender, totalAmount);lastClaimed[msg.sender] = block.timestamp;}
                    // if holder has 1 or more NFTs mint caller, set holder claims amount x total NFT balance; (100 tokens x 5 NFTs = 500 tokens)
                
                
                //DEV NOTES: all inputs in "set amount functions" and "set fee functions" must be entered in solidity. (1 token = 1000000000000000000)
                function setNftContract (address _nftContract) public onlyRole(PAUSER_ROLE) { nftContract = INFT(_nftContract);}
                function setHoldersClaimAmount (uint256 _holdersClaimAmount) public onlyRole(PAUSER_ROLE) { holdersClaimAmount = _holdersClaimAmount;}

                function setStakingTokenBalance (uint256 _stakingTokenBalance) public onlyRole(PAUSER_ROLE) { stakingTokenBalance = _stakingTokenBalance;
                }
                function setClaimAmount (uint256 _claimAmount) public onlyRole(PAUSER_ROLE) { claimAmount = _claimAmount; }
                function setMaxClaims (uint256 _maxClaims) public onlyRole(PAUSER_ROLE) { maxClaims = _maxClaims; }
                function setWhitelistClaims (uint256 _whitelistClaims) public onlyRole(PAUSER_ROLE) { whitelistClaims = _whitelistClaims; }

                function setWhitelistTokenAmount (uint256 _whitelistTokenAmount) external onlyRole(PAUSER_ROLE) {  
                  whitelistTokenAmount = _whitelistTokenAmount;
                  }
                function setCharityPercent (uint256 _charityPercent) external onlyRole(PAUSER_ROLE) { charityPercent = _charityPercent;}
                function setCharityAddress (address _charityAddress)public onlyRole(MINTER_ROLE) { 
                    charityAddress = _charityAddress;
                }
                function setBurnPercent (uint256 _burnPercent)public onlyRole(MINTER_ROLE) { burnPercent = _burnPercent;}

                function setStakingPercent (uint256 _stakingPercent) public onlyRole(PAUSER_ROLE) { stakingPercent = _stakingPercent;}
                 function mint(address to, uint256 amount) 
                 public onlyRole(MINTER_ROLE) { _mint(to, amount); 
                 } 
                function blacklistAddress(address _targetAddress) public onlyRole(PAUSER_ROLE) { 
                    isBlacklisted[_targetAddress] = true; 
                } 
                function removeBlacklistAddress(address _targetAddress) public onlyRole(PAUSER_ROLE) { 
                isBlacklisted[_targetAddress] = false;
              } 
               function whitelistAddress(address _targetAddress) public onlyRole(PAUSER_ROLE) { 
                    isWhitelisted[_targetAddress] = true;
              }
              function removeWhitelistAddress(address _targetAddress) public onlyRole(PAUSER_ROLE) { 
                    isWhitelisted[_targetAddress] = false;
                    hasClaimed[_targetAddress] = false; //resets claim status when removed from whitelist.
              }
               function grantMinterRole (address _targetAddress) public onlyRole(PAUSER_ROLE) { _grantRole(MINTER_ROLE, _targetAddress);} 

              function transfer(address recipient, uint256 amount) public notBlacklisted override returns (bool) {
                uint256 burnAmount = amount * burnPercent/10000;
                uint256 charityAmount = amount * charityPercent/10000;
                   require(!isBlacklisted[msg.sender], 
                  "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse And Is No Longer Able To Use Use Our Contract"); 
                  require(!isBlacklisted[recipient], 
                 "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse And Is No Longer Able To Use Use Our Contract"); 
             if (amount >= 1000000 * 10 ** decimals()) { emit WhaleTransfer(msg.sender, recipient, amount); 
              } 
                 else if (amount >= 500000 * 10 ** decimals() && amount <= 999999 * 10 ** decimals()) { 
                      emit SharkTransfer(msg.sender, recipient, amount); } 
                    else if (amount >= 250000 * 10 ** decimals() && amount <= 499999 * 10 ** decimals()) { 
                     emit TadpolTransfer(msg.sender, recipient, amount);
                      } 
                      if (isWhitelisted[msg.sender]){ require (balanceOf(msg.sender)>= amount, "insuffecient balance to cover transfer and burn amount");
                         return super.transfer(recipient, amount); }
                     else require (balanceOf(msg.sender)>= amount + burnAmount + charityAmount, "insuffecient balance to cover transfer and burn amount");
                      _burn(msg.sender, burnAmount);
                      _transfer(msg.sender, charityAddress, charityAmount);
                     return super.transfer(recipient, amount); 
                 } 
                 function transferFrom(address sender, address recipient, uint256 amount) 
                 public notBlacklisted override returns (bool) { 
                    require(!isBlacklisted[sender], 
                    "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse And Is No Longer Able To Use Use Our Contract"); 
                    require(!isBlacklisted[recipient], 
                    "Either The Sender Or Recipient Wallet Is Blacklisted For Project Misuse And Is No Longer Able To Use Use Our Contract"); 
                    if (amount >= 1000000 * 10 ** decimals()) { emit WhaleTransfer(sender, recipient, amount); 
                    } 
                    else if (amount >= 500000 * 10 ** decimals() && amount <= 999999 * 10 ** decimals()) { 
                        emit SharkTransfer(sender, recipient, amount); } 
                        else if (amount >= 250000 * 10 ** decimals() && amount <= 499999 * 10 ** decimals()) { 
                            emit TadpolTransfer(sender, recipient, amount); 
                            } 
                            return super.transferFrom(sender, recipient, amount);
                            } 
                            function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable) { 
                                super._update(from, to, value); 
                                } 
  }
