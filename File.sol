// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// SafeMath library to prevent overflow and underflow
library SafeMath {
    /**
     * @dev Adds two unsigned integers, returns the result, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, returns the result, reverts on underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Multiplies two unsigned integers, returns the result, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Divides two unsigned integers, returns the result, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

// Provides information about the current execution context
abstract contract Context {
    /**
     * @dev Returns the address of the caller of the function.
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Interface for the ERC20 standard as defined in the EIP
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be allowed to spend on behalf of `owner`.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// Optional metadata functions from the ERC20 standard
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// Implementation of the ERC20 interface
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    // Constants for the token's name and symbol
    string private constant TOKEN_NAME = "EcoWattCoin";
    string private constant TOKEN_SYMBOL = "EWTC";
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;

    /**
     * @dev Sets the values for {name} and {symbol}.
     */
    constructor() {
        _name = TOKEN_NAME;
        _symbol = TOKEN_SYMBOL;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return balances[account];
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return allowances[owner][spender];
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        require(amount <= totalSupply(), "ERC20: approve amount exceeds total supply");

        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance.sub(amount));
        return true;
    }

    /**
     * @dev Increases the allowance granted to `spender` by the caller.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        uint256 currentAllowance = allowances[_msgSender()][spender];
        uint256 newAllowance = currentAllowance.add(addedValue);

        // Checks that the new allowance does not exceed totalSupply
        require(newAllowance <= totalSupply(), "ERC20: allowance exceeds total supply");

        _approve(_msgSender(), spender, newAllowance);
        return true;
    }

    /**
     * @dev Decreases the allowance granted to `spender` by the caller.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        uint256 currentAllowance = allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance.sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");

        uint256 senderBalance = balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        balances[sender] = senderBalance.sub(amount);
        balances[recipient] = balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`'s tokens.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing the total supply.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply.add(amount) <= MAX_SUPPLY, "ERC20: minting exceeds max supply");

        _totalSupply = _totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        balances[account] = accountBalance.sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}

// Contract that defines ownership and secondary ownership of the contract
abstract contract Ownable is Context {
    address private _owner;
    address private _secondaryOwner;

    /**
     * @dev Emitted when ownership of the contract is transferred from one account (`previousOwner`) to another (`newOwner`).
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Emitted when a secondary owner is set for the contract.
     */
    event SecondaryOwnerSet(address indexed previousSecondaryOwner, address indexed newSecondaryOwner);

    /**
     * @dev Initializes the contract, setting the initial owner to `initialOwner`.
     */
    constructor(address initialOwner) {
        require(initialOwner != address(0), "Ownable: initial owner is the zero address");
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current secondary owner.
     */
    function secondaryOwner() public view virtual returns (address) {
        return _secondaryOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner or secondary owner.
     */
    modifier onlyOwnerOrSecondary() {
        require(_msgSender() == owner() || _msgSender() == _secondaryOwner, "Ownable: caller is not the owner or secondary owner");
        _;
    }

    /**
     * @dev Sets the secondary owner of the contract.
     */
    function setSecondaryOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new secondary owner is the zero address");
        require(newOwner != owner(), "Ownable: new secondary owner is the same as the current owner");
        require(newOwner != _secondaryOwner, "Ownable: new secondary owner is the same as the current secondary owner");
        emit SecondaryOwnerSet(_secondaryOwner, newOwner);
        _secondaryOwner = newOwner;
    }

    /**
     * @dev Revokes the secondary ownership of the contract.
     */
    function revokeSecondaryOwner() public onlyOwner {
        require(_secondaryOwner != address(0), "Ownable: secondary owner is not set");
        emit SecondaryOwnerSet(_secondaryOwner, address(0));
        _secondaryOwner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// Contract that prevents reentrant calls to a function
abstract contract ReentrancyGuard {
    uint256 private _status;

    /**
     * @dev Initializes the contract setting the reentrancy guard status to not entered.
     */
    constructor() {
        _status = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     */
    modifier nonReentrant() {
        require(_status != 2, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }
}

// Contract that allows children to implement an emergency stop mechanism
abstract contract Pausable is Context {
    
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// Contract that implements a timelock mechanism with expiration for certain actions
abstract contract Timelock {
    using SafeMath for uint256;

    uint256 private constant _DELAY = 20; // Delay in blocks before an action can be executed
    uint256 private constant _EXPIRATION_DURATION = 20; // Additional blocks after which the action expires
    mapping(bytes32 => uint256) private _timelock;

    /**
     * @dev Emitted when an action is queued with a specified block number for execution.
     */
    event ActionQueued(bytes32 indexed actionId, uint256 blockNumber);

    /**
     * @dev Emitted when a queued action is executed.
     */
    event ActionExecuted(bytes32 indexed actionId);

    /**
     * @dev Emitted when a queued action is cancelled.
     */
    event ActionCancelled(bytes32 indexed actionId);

    /**
     * @dev Emitted when a queued action expires due to being unexecuted past the expiration duration.
     */
    event ActionExpired(bytes32 indexed actionId);

    /**
     * @dev Modifier to make a function callable only after the timelock period has passed and before it expires.
     */
    modifier timelocked(bytes32 actionId) {
        uint256 unlockTime = _timelock[actionId];
        require(unlockTime != 0, "Timelock: action not queued");
        require(block.number >= unlockTime, "Timelock: action locked");
        require(block.number <= unlockTime.add(_EXPIRATION_DURATION), "Timelock: action expired");
        _;
        delete _timelock[actionId]; // Reset the timelock after execution
    }

    /**
     * @dev Queues an action with a delay in blocks before it can be executed.
     */
    function queueAction(bytes32 actionId) internal {
        require(_timelock[actionId] <= block.number, "Timelock: action already queued or still pending");
        _timelock[actionId] = block.number.add(_DELAY);
        emit ActionQueued(actionId, block.number);
    }

    /**
     * @dev Cancels a queued action.
     */
    function cancelAction(bytes32 actionId) internal {
        require(_timelock[actionId] != 0, "Timelock: action not queued");
        delete _timelock[actionId];
        emit ActionCancelled(actionId);
    }

    /**
     * @dev Checks if a queued action has expired.
     */
    function checkExpiration(bytes32 actionId) public {
        uint256 unlockTime = _timelock[actionId];
        if (unlockTime != 0 && block.number > unlockTime.add(_EXPIRATION_DURATION)) {
            delete _timelock[actionId];
            emit ActionExpired(actionId);
        }
    }
}

// Contract that implements role-based access control
abstract contract RoleBasedAccessControl is Context {
    mapping(address => bool) private _minters;
    mapping(address => bool) private _burners;
    mapping(address => bool) private _admins;
    uint256 private _adminCount;

    /**
     * @dev Emitted when a new minter is added.
     */
    event MinterAdded(address indexed account);

    /**
     * @dev Emitted when a minter is removed.
     */
    event MinterRemoved(address indexed account);

    /**
     * @dev Emitted when a new burner is added.
     */
    event BurnerAdded(address indexed account);

    /**
     * @dev Emitted when a burner is removed.
     */
    event BurnerRemoved(address indexed account);

    /**
     * @dev Emitted when a new admin is added.
     */
    event AdminAdded(address indexed account);

    /**
     * @dev Emitted when an admin is removed.
     */
    event AdminRemoved(address indexed account);

    /**
     * @dev Initializes the contract setting the deployer as the first admin.
     */
    constructor() {
        _admins[_msgSender()] = true;
        _adminCount = 1;
    }

    /**
     * @dev Throws if called by any account other than an admin.
     */
    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "RoleBasedAccessControl: caller is not an admin");
        _;
    }

    /**
     * @dev Throws if called by any account other than a minter.
     */
    modifier onlyMinter() {
        require(isMinter(_msgSender()), "RoleBasedAccessControl: caller is not a minter");
        _;
    }

    /**
     * @dev Throws if called by any account other than a burner.
     */
    modifier onlyBurner() {
        require(isBurner(_msgSender()), "RoleBasedAccessControl: caller is not a burner");
        _;
    }

    /**
     * @dev Adds a new minter role to `account`.
     */
    function addMinter(address account) public onlyAdmin {
        require(account != address(0), "RoleBasedAccessControl: minter is the zero address");
        require(!isMinter(account), "RoleBasedAccessControl: account is already a minter");
        _minters[account] = true;
        emit MinterAdded(account);
    }

    /**
     * @dev Removes the minter role from `account`.
     */
    function removeMinter(address account) public onlyAdmin {
        require(isMinter(account), "RoleBasedAccessControl: account is not a minter");
        _minters[account] = false;
        emit MinterRemoved(account);
    }

    /**
     * @dev Returns true if the account is a minter.
     */
    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    /**
     * @dev Adds a new burner role to `account`.
     */
    function addBurner(address account) public onlyAdmin {
        require(account != address(0), "RoleBasedAccessControl: burner is the zero address");
        require(!isBurner(account), "RoleBasedAccessControl: account is already a burner");
        _burners[account] = true;
        emit BurnerAdded(account);
    }

    /**
     * @dev Removes the burner role from `account`.
     */
    function removeBurner(address account) public onlyAdmin {
        require(isBurner(account), "RoleBasedAccessControl: account is not a burner");
        _burners[account] = false;
        emit BurnerRemoved(account);
    }

    /**
     * @dev Returns true if the account is a burner.
     */
    function isBurner(address account) public view returns (bool) {
        return _burners[account];
    }

    /**
     * @dev Adds a new admin role to `account`.
     */
    function addAdmin(address account) public onlyAdmin {
        require(account != address(0), "RoleBasedAccessControl: admin is the zero address");
        require(!isAdmin(account), "RoleBasedAccessControl: account is already an admin");
        _admins[account] = true;
        _adminCount++;
        emit AdminAdded(account);
    }

    /**
     * @dev Removes the admin role from `account`.
     */
    function removeAdmin(address account) public onlyAdmin {
        require(isAdmin(account), "RoleBasedAccessControl: account is not an admin");
        require(_adminCount > 1, "RoleBasedAccessControl: cannot remove the last admin");
        _admins[account] = false;
        _adminCount--;
        emit AdminRemoved(account);
    }

    /**
     * @dev Returns true if the account is an admin.
     */
    function isAdmin(address account) public view returns (bool) {
        return _admins[account];
    }
}

// Contract that implements a timelock for ownership transfer
abstract contract TimelockTransferOwnership is Ownable {
    using SafeMath for uint256;

    address private _proposedOwner;
    uint256 private _ownershipTransferTimelock;
    uint256 private constant _TRANSFER_DELAY_IN_BLOCKS = 20; // Number of blocks delay before the transfer can be executed
    uint256 private constant _EXPIRATION_DURATION = 20; // Number of blocks after which the transfer expires

    /**
     * @dev Emitted when an ownership transfer is initiated with a specified block number for execution.
     */
    event OwnershipTransferInitiated(address indexed currentOwner, address indexed proposedOwner, uint256 executionBlock);

    /**
     * @dev Emitted when an ownership transfer is canceled.
     */
    event OwnershipTransferCancelled(address indexed currentOwner, address indexed proposedOwner);

    /**
     * @dev Emitted when an ownership transfer expires without being executed.
     */
    event OwnershipTransferExpired(address indexed currentOwner, address indexed proposedOwner);

    /**
     * @dev Modifier that ensures the ownership transfer can only be executed after the timelock period has passed and before the action expires.
     */
    modifier onlyAfterTimelock() {
        require(_ownershipTransferTimelock != 0, "Timelock: ownership transfer not queued");
        require(block.number >= _ownershipTransferTimelock, "Timelock: ownership transfer still locked");
        require(block.number <= _ownershipTransferTimelock.add(_EXPIRATION_DURATION), "Timelock: ownership transfer expired");
        _;
        delete _ownershipTransferTimelock; // Reset the timelock after execution
    }

    /**
     * @dev Initiates the ownership transfer process with a timelock.
     */
    function initiateOwnershipTransfer(address newOwner) public onlyOwner {
        require(newOwner != address(0), "TimelockTransferOwnership: new owner is the zero address");
        require(newOwner != owner(), "TimelockTransferOwnership: new owner must be different from current owner");
        require(newOwner != secondaryOwner(), "TimelockTransferOwnership: new owner cannot be the current secondary owner");
        require(_ownershipTransferTimelock <= block.number, "Timelock: previous ownership transfer still pending or active");

        _proposedOwner = newOwner;
        _ownershipTransferTimelock = block.number.add(_TRANSFER_DELAY_IN_BLOCKS);
        emit OwnershipTransferInitiated(owner(), newOwner, _ownershipTransferTimelock);
    }

    /**
     * @dev Executes the ownership transfer after the timelock has passed, provided the transfer has not expired.
     */
    function executeOwnershipTransfer() public onlyOwner onlyAfterTimelock {
        require(_proposedOwner != address(0), "TimelockTransferOwnership: no owner proposed");
        _transferOwnership(_proposedOwner);
        _proposedOwner = address(0); // Reset the proposed owner after the transfer
    }

    /**
     * @dev Cancels the initiated ownership transfer process.
     */
    function cancelOwnershipTransfer() public onlyOwner {
        require(_proposedOwner != address(0), "TimelockTransferOwnership: no owner proposed");
        address cancelledOwner = _proposedOwner;
        _proposedOwner = address(0);
        _ownershipTransferTimelock = 0;
        emit OwnershipTransferCancelled(owner(), cancelledOwner);
    }

    /**
     * @dev Checks if the ownership transfer has expired and automatically cancels it if expired.
     */
    function checkOwnershipTransferExpiration() public {
        if (_ownershipTransferTimelock != 0 && block.number > _ownershipTransferTimelock.add(_EXPIRATION_DURATION)) {
            address expiredOwner = _proposedOwner;
            _proposedOwner = address(0);
            _ownershipTransferTimelock = 0;
            emit OwnershipTransferExpired(owner(), expiredOwner);
        }
    }

    /**
     * @dev Returns the address of the proposed owner.
     */
    function proposedOwner() public view returns (address) {
        return _proposedOwner;
    }

    /**
     * @dev Returns the block number when the ownership transfer can be executed.
     */
    function ownershipTransferTimelock() public view returns (uint256) {
        return _ownershipTransferTimelock;
    }
}

// Main contract for EcoWattCoin token implementing all the functionalities
contract EcoWattCoin is ERC20, Ownable, ReentrancyGuard, Pausable, Timelock, RoleBasedAccessControl, TimelockTransferOwnership {
    using SafeMath for uint256;

    uint256 private constant INITIAL_SUPPLY = 10_000_000 * 10**18;
    address private constant ZERO_ADDRESS = address(0);

    uint256 private _actionCounter;
    bool private _actionPending; // New state variable to track if an action is pending
    uint256 private immutable _nonBurnableSupply; // Updated to be immutable as suggested

    /**
     * @dev Emitted when tokens are minted.
     */
    event Mint(address indexed to, uint256 amount);

    /**
     * @dev Emitted when tokens are burned.
     */
    event Burn(address indexed from, uint256 amount);

    /**
     * @dev Emitted when unexpected Ether is received.
     */
    event UnexpectedEtherReceived(address sender, uint256 amount);

    struct MintAction {
        address to;
        uint256 amount;
        uint256 blockNumber;
    }

    struct BurnAction {
        address from;
        uint256 amount;
        uint256 blockNumber;
    }

    mapping(bytes32 => MintAction) private _mintActions;
    mapping(bytes32 => BurnAction) private _burnActions;

    /**
     * @dev Initializes the contract with the initial supply assigned to the `initialOwner`.
     */
    constructor(address initialOwner) ERC20() Ownable(initialOwner) {
        require(INITIAL_SUPPLY <= MAX_SUPPLY, "Initial supply exceeds max supply");
        _mint(initialOwner, INITIAL_SUPPLY);
        _nonBurnableSupply = INITIAL_SUPPLY; // Set the non-burnable supply to the initial supply and mark it as immutable
        _actionPending = false; // Initialize the actionPending flag as false
    }

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient` with non-reentrancy and pause checks.
     */
    function transfer(address recipient, uint256 amount) public virtual override nonReentrant whenNotPaused returns (bool) {
        return super.transfer(recipient, amount);
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism with non-reentrancy and pause checks.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override nonReentrant whenNotPaused returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Queues a minting action that must be executed after a timelock period.
     */
    function queueMint(address to, uint256 amount) public onlyOwnerOrSecondary onlyMinter whenNotPaused {
        require(to != ZERO_ADDRESS, "ERC20: mint to the zero address");
        require(amount > 0, "ERC20: mint amount must be greater than zero");
        require(totalSupply().add(amount) <= MAX_SUPPLY, "ERC20: minting exceeds max supply");
    
        // Redefine o estado `_actionPending` se necessário
        if (!_actionPending) {
            _actionPending = true; // Set the actionPending flag to true

            uint256 blockNumber = block.number;
            bytes32 actionId = keccak256(abi.encodePacked("mint", to, amount, blockNumber, _actionCounter++));
            _mintActions[actionId] = MintAction(to, amount, blockNumber);
            queueAction(actionId);
        } else {
            revert("ERC20: another action is already pending");
        }
    }

    /**
     * @dev Executes a previously queued minting action after the timelock has passed.
     */
    function executeMint(bytes32 actionId) public onlyOwnerOrSecondary timelocked(actionId) whenNotPaused {
        MintAction memory action = _mintActions[actionId];
        require(action.to != ZERO_ADDRESS, "ERC20: mint to the zero address");
        require(action.amount > 0, "ERC20: mint amount must be greater than zero");
        require(totalSupply().add(action.amount) <= MAX_SUPPLY, "ERC20: minting exceeds max supply");

        _mint(action.to, action.amount);
        emit Mint(action.to, action.amount);
        delete _mintActions[actionId];

        _actionPending = false; // Reset the actionPending flag to false
    }

    /**
     * @dev Queues a burning action that must be executed after a timelock period.
     */
    function queueBurn(address from, uint256 amount) public onlyOwnerOrSecondary onlyBurner whenNotPaused {
        require(from != ZERO_ADDRESS, "ERC20: burn from the zero address");
        require(balanceOf(from) >= amount, "ERC20: burn amount exceeds balance");
        require(amount > 0, "ERC20: burn amount must be greater than zero");
        require(!_actionPending, "ERC20: another action is already pending");

        // Ensure that the amount to be burned does not include non-burnable supply
        require(totalSupply().sub(amount) >= _nonBurnableSupply, "ERC20: cannot burn initial supply");

        _actionPending = true; // Set the actionPending flag to true

        uint256 blockNumber = block.number;
        bytes32 actionId = keccak256(abi.encodePacked("burn", from, amount, blockNumber, _actionCounter++));
        _burnActions[actionId] = BurnAction(from, amount, blockNumber);
        queueAction(actionId);
    }

    /**
     * @dev Executes a previously queued burning action after the timelock has passed.
     */
    function executeBurn(bytes32 actionId) public onlyOwnerOrSecondary timelocked(actionId) whenNotPaused {
        BurnAction memory action = _burnActions[actionId];
        require(action.from != ZERO_ADDRESS, "ERC20: burn from the zero address");
        require(action.amount > 0, "ERC20: burn amount must be greater than zero");
        require(balanceOf(action.from) >= action.amount, "ERC20: burn amount exceeds balance");

        // Ensure that the amount to be burned does not include non-burnable supply
        require(totalSupply().sub(action.amount) >= _nonBurnableSupply, "ERC20: cannot burn initial supply");

        _burn(action.from, action.amount);
        emit Burn(action.from, action.amount);
        delete _burnActions[actionId];

        _actionPending = false; // Reset the actionPending flag to false
    }

    /**
     * @dev Cancels a previously queued minting action.
     */
    function cancelMint(bytes32 actionId) public onlyOwnerOrSecondary {
        require(_mintActions[actionId].to != address(0), "ERC20: mint action not found");
        delete _mintActions[actionId];
        cancelAction(actionId);

        _actionPending = false; // Reset the actionPending flag to false
    }

    /**
     * @dev Cancels a previously queued burning action.
     */
    function cancelBurn(bytes32 actionId) public onlyOwnerOrSecondary {
        require(_burnActions[actionId].from != address(0), "ERC20: burn action not found");
        delete _burnActions[actionId];
        cancelAction(actionId);

        _actionPending = false; // Reset the actionPending flag to false
    }

    /**
     * @dev Pauses the contract, preventing certain operations.
     */
    function pause() public onlyOwnerOrSecondary {
        _pause();
    }

    /**
     * @dev Unpauses the contract, allowing operations to resume.
     */
    function unpause() public onlyOwnerOrSecondary {
        _unpause();
    }

    /**
     * @dev Withdraws Ether from the contract to the owner's address.
     */
    function withdrawEther() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Contract has no Ether");
        payable(owner()).transfer(balance);
    }

    /**
     * @dev Withdraws ERC20 tokens from the contract to the owner's address.
     */     
    function withdrawToken(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "Contract has no tokens of this type");
        require(token.transfer(owner(), tokenBalance), "Token transfer failed");
    }

    /**
     * @dev Fallback function to handle unexpected Ether transfers.
     */
    fallback() external payable {
        emit UnexpectedEtherReceived(msg.sender, msg.value);
        revert("Fallback: unexpected transfer received");
    }

    /**
     * @dev Function to handle direct Ether transfers.
     */
    receive() external payable {
        emit UnexpectedEtherReceived(msg.sender, msg.value);
        revert("Receive: ETH not accepted");
    }
}
