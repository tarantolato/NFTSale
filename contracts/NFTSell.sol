//"SPDX-License-Identifier: MIT"

pragma solidity ^0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        // The account hash of 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned for non-contract addresses,
        // so-called Externally Owned Account (EOA)
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract NFTSell is Ownable {
    using SafeMath for uint256;
    using Address for address;

    struct PrivateSaleWhiteListStruct {
        address addresses;
        bool inserted;
        uint256 tokenBuyed;
        uint256 bnbBuyed;
        bool deleted;
        bool blackListed;
        uint claimTime; // data in cui ha ritirato i tokens
    }
    mapping (address => PrivateSaleWhiteListStruct) private _PrivateSaleWhiteList;
    address[] private _PrivateSaleWhiteListAccounts;

    uint256 private rate; // rate
    uint256 private minTrade; // 0.5 bnb
    uint256 private maxTrade; // 1 bnb

    // address del wallet
    address payable private wallet;
    uint private startDate;
    uint private endDate;
    uint private claimDate;
    bool private finalized;
    uint256 private bnbRemaining;
    bool private automode;

    IBEP20 private token;

    event TokensPurchased(address buyer, uint256 BNBSold, uint256 tokenAmount, uint256 rate);
    event WithdrawAll(address wallet, uint256 total);
    event TokensClaimed(address buyer, uint256 tokenAmount);

    constructor ()  {
    }

    //////////////////////////// funzioni del contratto di base /////////////////////////////////////

    ///////////////////////////////// funzioni per la private Sale //////////////////////////////////
    function buyTokens () public payable returns (bool) {
        uint256 bnbAlreadyBuyed;
        uint256 bnbTotalBuyed;
        uint256 tokensAlreadyBuyed;
        uint256 tokensTotalBuyed;
        uint256 tokenDecimals = 9;
        // Calculate the number of tokens to buy
        uint256 tokenAmount = (((msg.value).mul(rate)).div(10**18)).mul(
            10**tokenDecimals
        );
        require(isPrivateSaleActive(), "The Private Sale isn't active");
        require(
            msg.value == minTrade || msg.value == maxTrade,
            "The BNB amount should be minTrade or maxTrade"
        );
        require(get_InsertedPrivateSaleWhiteList(msg.sender), "The address it isn't in whitelist");
        require(!get_BlacklistedPrivateSaleWhiteList(msg.sender), "The address it is in blacklist");
        // Emit an event
        if (automode) bnbRemaining = bnbRemaining.sub(msg.value);
        bnbAlreadyBuyed =  get_BnbBuyedPrivateSaleWhiteList(msg.sender);
        tokensAlreadyBuyed =  get_TokenBuyedPrivateSaleWhiteList(msg.sender);
        bnbTotalBuyed = bnbAlreadyBuyed.add(msg.value);
        tokensTotalBuyed = tokensAlreadyBuyed.add(tokenAmount);
        set_ValuesPrivateSaleWhiteList(msg.sender,tokensTotalBuyed,bnbTotalBuyed);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount, rate);
        return true;
    }

    function claimTokens () public returns (bool) {
        uint256 tokensBuyed;
        require(isClaimActive(), "Claim isn't active yet");
        require(get_InsertedPrivateSaleWhiteList(msg.sender), "The address it isn't in claimlist");
        require(!get_BlacklistedPrivateSaleWhiteList(msg.sender), "The address it is in blacklist");
        require(get_TokenBuyedPrivateSaleWhiteList(msg.sender) > 0, "You have no tokens to claim");
        require(get_ClaimTimePrivateSaleWhiteList(msg.sender) == 0, "You have already claimed your tokens");
        // Emit an event
        tokensBuyed = get_TokenBuyedPrivateSaleWhiteList(msg.sender);
        token.transfer(msg.sender, tokensBuyed);
        set_ClaimTimePrivateSaleWhiteList(msg.sender, block.timestamp);
        set_TokenBuyedPrivateSaleWhiteList(msg.sender, 0);
        emit TokensClaimed(msg.sender, tokensBuyed);
        return true;
    }

    function withdraw() public onlyOwner {
        uint256 totalToTransfer = address(this).balance; //esprime il balance in BNB
        require(totalToTransfer > 0, "The balance should be >0");
        wallet.transfer(totalToTransfer);
        emit WithdrawAll(wallet, totalToTransfer);
    }

    function isPrivateSaleActive() public view returns (bool isActive) {
        uint nowDate = block.timestamp;
        isActive =
            nowDate >= startDate &&
            nowDate <= endDate &&
            !finalized &&
            bnbRemaining > 0;
    }

    function isClaimActive() public view returns (bool isActive) {
        uint nowDate = block.timestamp;
        isActive =
            nowDate >= claimDate;
    }

    function set_AutoCalculateRemainingBNBToSell (bool _automode) public onlyOwner {
        automode = _automode;
    }

    function get_AutoCalculateRemainingBNBToSell () public view returns (bool) {
        return automode;
    }

    function currentTime () public view returns (uint) {
        return block.timestamp;
    }

    function setFinalize (bool _finalized) public onlyOwner {
        finalized = _finalized;
    }

    function getFinalize () public view returns (bool) {
        return finalized;
    }

    // Set wallet address whre will place the amount of sale
    function setWallet (address _wallet) public onlyOwner {
        wallet = payable(_wallet);
    }

    function getWallet () public view returns (address) {
        return wallet;
    }

    function setToken(address _token) public onlyOwner {
        token = IBEP20(_token);
    }

    function setRate (uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function getRate () public view returns (uint256) {
        return rate;
    }

    function setStartDate (uint _start) public onlyOwner {
        startDate = _start;
    }

    function getStartDate () public view returns (uint) {
        return startDate;
    }

    function setEndDate (uint _end) public onlyOwner {
        endDate = _end;
    }

    function getEndDate () public view returns (uint) {
        return endDate ;
    }

    function setClaimDate (uint _claim) public onlyOwner {
        claimDate = _claim;
    }

    function getClaimDate () public view returns (uint) {
        return claimDate ;
    }

    function setMinTrade (uint256 _min) public onlyOwner {
        minTrade = _min;
    }

    function getMinTrade () public view returns (uint256) {
        return minTrade;
    }

    function setMaxTrade (uint256 _max) public onlyOwner {
        maxTrade = _max;
    }

    function getMaxTrade () public view returns (uint256) {
        return maxTrade;
    }

    function setbnbRemaining (uint256 _bnbremaining) public onlyOwner {
        bnbRemaining = _bnbremaining;
    }

    // funzione che restituisce i BNB ancora rimanenti da comprare
    function getbnbRemaining () public view returns (uint256) {
        return bnbRemaining;
    }

    function setAutomode (bool _automode) public onlyOwner {
        automode = _automode;
    }

    function getAutomode () public view returns (bool) {
        return automode;
    }

    // fuunzione che calcola quanto manca alla partenza
    function getStarIntDate () public view returns (uint) {
        uint starIntDate;
        if (block.timestamp >= startDate) starIntDate = 0;
        else starIntDate =  startDate.sub(block.timestamp);
        return starIntDate;
    }

    // fuunzione che calcola quanto manca alla fine
    function getEndIntDate () public view returns (uint) {
        uint endIntDate;
        if (block.timestamp >= endDate) endIntDate = 0;
        else endIntDate =  endDate.sub(block.timestamp);
        return endIntDate;
    }

    // fuunzione che calcola quanto manca al cliam
    function getClaimIntDate () public view returns (uint) {
        uint claimIntDate;
        if (block.timestamp >= claimDate) claimIntDate = 0;
        else claimIntDate =  claimDate.sub(block.timestamp);
        return claimIntDate;
    }

    function setStartParameters(
        uint256 _rate,
        uint256 _minTrade,
        uint256 _maxTrade,
        address _wallet,
        uint _startDate,
        uint _endDate,
        uint _claimDate,
        bool _finalized,
        uint256 _bnbRemaining,
        bool _automode,
        address _token
        ) public onlyOwner {

        setRate (_rate); // 18000000000
        setMinTrade (_minTrade); // 500000000000000000 = 0.5 bnb
        setMaxTrade (_maxTrade); // 1000000000000000000 = 1 bnb
        setWallet (_wallet);
        setStartDate (_startDate); // UnixTime
        setEndDate (_endDate); // UnixTime
        setClaimDate (_claimDate); // UnixTime
        setFinalize (_finalized); // false
        setbnbRemaining (_bnbRemaining); // 60000000000000000000 = 50 BNB
        setToken (_token);
        setAutomode (_automode); // se false non decrementa i BNB rimanenti e camuffa la private sale
    }

    function addAccountInWhiteList (address[] memory whiteListAddrs) public onlyOwner {
        uint256 size = whiteListAddrs.length;
        address keyAddress;
        if (size>0) {
            for (uint256 i = 0; i < size ; i++) {
                keyAddress = whiteListAddrs[i];
                set_ValuesPrivateSaleWhiteList(keyAddress,0,0);
            }
        }
    }

    function getAllBnbBuyed () public view returns (uint256) {
        uint256 size = _PrivateSaleWhiteListAccounts.length;
        address keyAddress;
        uint256 BnbBuyedFromUser;
        uint256 AllBnbBuyed = 0;
        if (size>0) {
            for (uint256 i = 0; i < size ; i++) {
                keyAddress = _PrivateSaleWhiteListAccounts[i];
                BnbBuyedFromUser = _PrivateSaleWhiteList[keyAddress].bnbBuyed;
                if (BnbBuyedFromUser > 0) AllBnbBuyed = AllBnbBuyed.add(BnbBuyedFromUser);
            }
        }
        return AllBnbBuyed;
    }

    function getAllTokenBuyed () public view returns (uint256) {
        uint256 size = _PrivateSaleWhiteListAccounts.length;
        address keyAddress;
        uint256 TokenBuyedFromUser;
        uint256 AllTokenBuyed = 0;
        if (size>0) {
            for (uint256 i = 0; i < size ; i++) {
                keyAddress = _PrivateSaleWhiteListAccounts[i];
                TokenBuyedFromUser = _PrivateSaleWhiteList[keyAddress].tokenBuyed;
                if (TokenBuyedFromUser > 0) AllTokenBuyed = AllTokenBuyed.add(TokenBuyedFromUser);
            }
        }
        return AllTokenBuyed;
    }

    function getAllUsersPartecipating () public view returns (uint256) {
        uint256 size = _PrivateSaleWhiteListAccounts.length;
        address keyAddress;
        uint256 AllUsers = 0;
        uint256 BnbBuyedFromUser;
        if (size>0) {
            for (uint256 i = 0; i < size ; i++) {
                keyAddress = _PrivateSaleWhiteListAccounts[i];
                BnbBuyedFromUser = _PrivateSaleWhiteList[keyAddress].bnbBuyed;
                if (BnbBuyedFromUser > 0) AllUsers = AllUsers.add(1);
            }
        }
        return AllUsers;
    }

    function isAddressInWhiteList (address addr) public view returns (bool) {
        uint256 size = _PrivateSaleWhiteListAccounts.length;
        address keyAddress;
        bool inserted;
        bool deleted;
        bool blackListed;
        if (size>0) {
        for (uint256 i = 0; i < size ; i++) {
            keyAddress = _PrivateSaleWhiteListAccounts[i];
            inserted = _PrivateSaleWhiteList[keyAddress].inserted;
            deleted = _PrivateSaleWhiteList[keyAddress].deleted;
            blackListed = _PrivateSaleWhiteList[keyAddress].blackListed;
            if (keyAddress == addr && inserted && !deleted && !blackListed) return true;
        }
        }
        return false;
    }

    // questa funzione serve se si vuole cambiare il numero dei token acquistati dai vari clienti dopo avere terminato la private sale, un adeguamento in corsa solo se necessario
    function upgradeTokenBuyed (uint256 newrate) public onlyOwner returns (bool) {
        uint256 size = _PrivateSaleWhiteListAccounts.length;
        address keyAddress;
        bool inserted;
        bool deleted;
        bool blackListed;
        uint256 bnbbuyed;
        uint256 newTokensBuyed;
        uint256 tokenDecimals = 9;
        if (size>0) {
            for (uint256 i = 0; i < size ; i++) {
                keyAddress = _PrivateSaleWhiteListAccounts[i];
                inserted = _PrivateSaleWhiteList[keyAddress].inserted;
                deleted = _PrivateSaleWhiteList[keyAddress].deleted;
                blackListed = _PrivateSaleWhiteList[keyAddress].blackListed;
                bnbbuyed = _PrivateSaleWhiteList[keyAddress].bnbBuyed;
                if (inserted && !deleted && !blackListed && bnbbuyed > 0) {
                    newTokensBuyed = (((bnbbuyed).mul(newrate)).div(10**18)).mul(10**tokenDecimals);
                    set_TokenBuyedPrivateSaleWhiteList(keyAddress,newTokensBuyed);
                }
            }
        }
        return true;
    }

    /////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////// funzioni del mapping PrivateSaleWhiteList ////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////

    function set_BnbBuyedPrivateSaleWhiteList (address addr, uint256 value) public onlyOwner {
        _PrivateSaleWhiteList[addr].bnbBuyed = value;
    }

    function get_BnbBuyedPrivateSaleWhiteList (address addr) public view returns (uint256) {
        return _PrivateSaleWhiteList[addr].bnbBuyed;
    }

    function set_TokenBuyedPrivateSaleWhiteList (address addr, uint256 value) public {
        _PrivateSaleWhiteList[addr].tokenBuyed = value;
    }

    function get_TokenBuyedPrivateSaleWhiteList (address addr) public view returns (uint256) {
        return _PrivateSaleWhiteList[addr].tokenBuyed;
    }

    function set_DeletedPrivateSaleWhiteList (address addr, bool value) public onlyOwner {
        _PrivateSaleWhiteList[addr].deleted = value;
    }

    function get_DeletedPrivateSaleWhiteList (address addr) public view returns (bool) {
        return _PrivateSaleWhiteList[addr].deleted;
    }

    function set_BlacklistedPrivateSaleWhiteList (address addr, bool value) public onlyOwner {
        _PrivateSaleWhiteList[addr].blackListed = value;
    }

    function get_BlacklistedPrivateSaleWhiteList (address addr) public view returns (bool) {
        return _PrivateSaleWhiteList[addr].blackListed;
    }

    function set_ClaimTimePrivateSaleWhiteList (address addr, uint value) public {
        _PrivateSaleWhiteList[addr].claimTime = value;
    }

    function get_ClaimTimePrivateSaleWhiteList (address addr) public view returns (uint) {
        return _PrivateSaleWhiteList[addr].claimTime;
    }

    function get_InsertedPrivateSaleWhiteList (address addr) public view returns (bool) {
        return _PrivateSaleWhiteList[addr].inserted;
    }

    function get_SizePrivateSaleWhiteList () public view returns (uint) {
        return _PrivateSaleWhiteListAccounts.length;
    }

    function get_AllPrivateSaleWhiteList () public view returns (address[] memory) {
        return _PrivateSaleWhiteListAccounts;
    }

    function set_ValuesPrivateSaleWhiteList(
        address addr,
        uint256 tokenbuyed,
        uint256 bnbbuyed
        ) private {

        if (_PrivateSaleWhiteList[addr].inserted){
            _PrivateSaleWhiteList[addr].tokenBuyed = tokenbuyed;
            _PrivateSaleWhiteList[addr].bnbBuyed = bnbbuyed;
        } else {
            _PrivateSaleWhiteList[addr].inserted = true;
            _PrivateSaleWhiteList[addr].tokenBuyed = tokenbuyed;
            _PrivateSaleWhiteList[addr].bnbBuyed = bnbbuyed;
            _PrivateSaleWhiteList[addr].deleted = false;
            _PrivateSaleWhiteList[addr].blackListed = false;
            _PrivateSaleWhiteList[addr].claimTime = 0;
            _PrivateSaleWhiteListAccounts.push(addr);
        }
    }
}
