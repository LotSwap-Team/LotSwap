pragma solidity ^0.8.0;


contract Vault {

    //Declaring variables to be used
    string public name;
    address admin;
    TokenBase public Itoken;
    uint256[] lastTime;
    uint256 amtReceived;
    uint256 month;
            
    constructor(address vaultAdmin, string memory _name) {
      
      //Assign admin and contract name on deploy
      admin = vaultAdmin;
      name = _name;
      //[contract startdate, last release date, month count] 
      lastTime = [block.timestamp, block.timestamp, 1]; 
            
    }

    //event to emit to transaction log
    event ReleaseInfo(
      address account,
      address token,
      uint256 amount,
      uint month
    );

    function safeRelease(address tokenORlpToken) public payable {

      //LotSwap Token Address
      address token = 0x10687B99F50877f2e7395d2cbfc10B61fe5682C2;
      //Liquidity Providing (LP) Token Address
      address lpToken = 0xc95C3dD5c330e9a2471A9e8fc47b7f445DeC0Af1;

      //Are we removing LOTS or the LP token?
      Itoken = TokenBase(tokenORlpToken);

      //If token, this is the monthly release amount
      if (tokenORlpToken == token){
        month = lastTime[2];
        
        //contract < 1 year, use this release amount
        if (block.timestamp < (lastTime[0] + 52 weeks)){

          amtReceived = 15000000000000000000000;
          //decimals  = 15000.000000000000000000

        }
        //contract >= 1 year < 2 years, use this release amount
        else if (block.timestamp < (lastTime[0] + 104 weeks) && block.timestamp >= (lastTime[0] + 52 weeks)){

          amtReceived = 30000000000000000000000;
          //decimals  = 30000.000000000000000000

        }
        //contract > 2 years, use this release amount
        else {

          /*
            * After Year 2, every month this will be what's available for the
            * community to use towards the distribution schedule. With 
            * governance it will be up to the token holders to decide how 
            * much of this token is used towards the distribution schedule,
            * how much gets put in reserve, if any will be airdropped and if
            * any will be burned in the process.
          */

          amtReceived = 487000000000000000000000;
          //decimals  = 487000.000000000000000000
 
        }
                 
      }
      //If removing LP token, this is the full amount of LP token to release
      else {
        amtReceived = 89445000000000000000000;
        //decimals  = 89445.000000000000000000
      }

      //LOTS balance OR LP balance in contract >= amount we are requesting
      require(Itoken.balanceOf(address(this)) >= amtReceived);

      //You must be admin to remove!!!
      require(msg.sender == admin, 'only admin');
   
      //Release monthly token amount at minimum 4 weeks from last removal
      if (tokenORlpToken == token) {
        if (block.timestamp > (lastTime[1] + 4 weeks)){
                    
          Itoken.transfer(msg.sender, amtReceived);
          //Update array with current time so next release occurs time now + 4 weeks
          lastTime[1] = block.timestamp;
          lastTime[2] = month + 1;

        }
      }

      //This will release LP token after 1 year
      if (tokenORlpToken == lpToken) {
        if (block.timestamp > (lastTime[0] + 52 weeks)){
          
          Itoken.transfer(msg.sender, amtReceived);

        }
      }

      // emit event to transaction log
      emit ReleaseInfo(msg.sender, address(Itoken), amtReceived, month);

    }
  
}
