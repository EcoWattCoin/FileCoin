// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// SafeMath from OpenZeppelin: Utility library for safe mathematical operations to prevent overflows and underflows.
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
     * @dev Subtracts two unsigned integers, returns the result, reverts on overflow.
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

// Context.sol: Abstract contract that provides information about the current execution context.
abstract contract Context {
    /**
     * @dev Returns the address of the current caller.
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Returns the data of the current call.
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// IERC20.sol: Interface for the ERC20 standard.
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// IERC20Metadata.sol: Interface for additional ERC20 metadata functions.
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// ERC20.sol: Implementation of the ERC20 standard with basic functionalities.
contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    // Mappings to store balances and allowances.
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // State variables for total supply, name, and symbol of the token.
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    // Constants for token name and symbol.
    string private constant TOKEN_NAME = "EcoWattCoin";
    string private constant TOKEN_SYMBOL = "EWC";

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
     * @dev Returns the number of decimals the token uses.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev Returns the total supply of the token.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the balance of `account`.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return balances[account];
    }

    /**
     * @dev Transfers `amount` tokens to `recipient`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` will be allowed to spend on behalf of `owner`.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return allowances[owner][spender];
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

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
     * @dev Increases the allowance of `spender` by `addedValue`.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        _approve(_msgSender(), spender, allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decreases the allowance of `spender` by `subtractedValue`.
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
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
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
        require(_totalSupply + amount <= 10000000 * 10**decimals(), "ERC20: minting exceeds max supply");

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

// Ownable.sol: Provides basic authorization control functions, simplifying the implementation of user permissions.
abstract contract Ownable is Context {
    address private _owner;
    address private _secondaryOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecondaryOwnerSet(address indexed previousSecondaryOwner, address indexed newSecondaryOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        require(initialOwner != address(0), "Ownable: initial owner is the zero address");
        require(initialOwner != _msgSender(), "Ownable: initial owner is the same as deployer");
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _msgSender(), "Ownable: new owner is the same as current owner");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Sets a secondary owner.
     */
    function setSecondaryOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new secondary owner is the zero address");
        require(newOwner != owner(), "Ownable: new secondary owner is the same as the current owner");
        emit SecondaryOwnerSet(_secondaryOwner, newOwner);
        _secondaryOwner = newOwner;
    }

    /**
     * @dev Revokes the secondary owner.
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

// ReentrancyGuard.sol: Helps prevent reentrant calls to a function.
abstract contract ReentrancyGuard {
    uint256 private _status;

    constructor() {
        _status = 1;
    }

    modifier nonReentrant() {
        require(_status != 2, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }
}

// Pausable.sol: Allows children to implement an emergency stop mechanism that can be triggered by an authorized account.
abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

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

// Timelock.sol: Implements a delay mechanism for specific actions.
abstract contract Timelock {
    using SafeMath for uint256;

    uint256 private constant _DELAY = 24 hours;
    mapping(bytes32 => uint256) private _timelock;

    event ActionQueued(bytes32 indexed actionId, uint256 timestamp);
    event ActionExecuted(bytes32 indexed actionId);
    event ActionCancelled(bytes32 indexed actionId);

    modifier timelocked(bytes32 actionId) {
        require(_timelock[actionId] != 0, "Timelock: action not queued");
        require(block.timestamp >= _timelock[actionId], "Timelock: action locked");
        _;
        _timelock[actionId] = 0; // Reset the timelock
    }

    function queueAction(bytes32 actionId) internal {
        require(_timelock[actionId] == 0, "Timelock: action already queued");
        _timelock[actionId] = block.timestamp.add(_DELAY);
        emit ActionQueued(actionId, block.timestamp);
    }

    function getTimelock(bytes32 actionId) public view returns (uint256) {
        return _timelock[actionId];
    }

    function cancelAction(bytes32 actionId) internal {
        require(_timelock[actionId] != 0, "Timelock: action not queued");
        delete _timelock[actionId];
        emit ActionCancelled(actionId);
    }
}

// RoleBasedAccessControl.sol: Implements role-based access control for minters and burners.
abstract contract RoleBasedAccessControl is Context {
    mapping(address => bool) private _minters;
    mapping(address => bool) private _burners;
    address private _admin;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);

    constructor() {
        _admin = _msgSender();
    }

    modifier onlyAdmin() {
        require(_msgSender() == _admin, "RoleBasedAccessControl: caller is not the admin");
        _;
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "RoleBasedAccessControl: caller is not a minter");
        _;
    }

    modifier onlyBurner() {
        require(isBurner(_msgSender()), "RoleBasedAccessControl: caller is not a burner");
        _;
    }

    function addMinter(address account) public onlyAdmin {
        require(account != address(0), "RoleBasedAccessControl: minter is the zero address");
        require(!isMinter(account), "RoleBasedAccessControl: account is already a minter");
        _minters[account] = true;
        emit MinterAdded(account);
    }

    function removeMinter(address account) public onlyAdmin {
        require(isMinter(account), "RoleBasedAccessControl: account is not a minter");
        _minters[account] = false;
        emit MinterRemoved(account);
    }

    function isMinter(address account) public view returns (bool) {
        return _minters[account];
    }

    function addBurner(address account) public onlyAdmin {
        require(account != address(0), "RoleBasedAccessControl: burner is the zero address");
        require(!isBurner(account), "RoleBasedAccessControl: account is already a burner");
        _burners[account] = true;
        emit BurnerAdded(account);
    }

    function removeBurner(address account) public onlyAdmin {
        require(isBurner(account), "RoleBasedAccessControl: account is not a burner");
        _burners[account] = false;
        emit BurnerRemoved(account);
    }

    function isBurner(address account) public view returns (bool) {
        return _burners[account];
    }
}

// MultisigVault.sol: Contract to manage multi-signature vaults.
contract MultisigVault {
    struct TransactionData {
        address proposer;
        bytes32 actionId;
        bytes data;
    }

    struct Transaction {
        TransactionData transactionData;
        mapping(address => bool) approvals;
        uint256 approvalCount;
    }

    mapping(bytes32 => TransactionData) public transactionData;
    mapping(bytes32 => Transaction) public transactions;
    mapping(address => bool) public signatories;
    uint256 public requiredSignatures;

    event TransactionProposed(bytes32 actionId, address proposer);
    event TransactionApproved(bytes32 actionId, address approver);
    event TransactionExecuted(bytes32 actionId);

    constructor(address[] memory _signatories, uint256 _requiredSignatures) {
        require(_requiredSignatures > 0 && _requiredSignatures <= _signatories.length, "Invalid required signatures");

        for (uint256 i = 0; i < _signatories.length; i++) {
            signatories[_signatories[i]] = true;
        }

        requiredSignatures = _requiredSignatures;
    }

    function proposeTransaction(bytes32 actionId, bytes memory data) external {
        require(signatories[msg.sender], "Only signatories can propose transactions");

        bytes32 transactionId = keccak256(abi.encodePacked(actionId, data));
        require(transactionData[transactionId].proposer == address(0), "Transaction already proposed");

        transactionData[transactionId] = TransactionData(msg.sender, actionId, data);
        transactions[transactionId].transactionData = transactionData[transactionId];

        emit TransactionProposed(actionId, msg.sender);
    }

    function approveTransaction(bytes32 actionId) external {
        require(signatories[msg.sender], "Only signatories can approve transactions");

        bytes32 transactionId = keccak256(abi.encodePacked(actionId));
        Transaction storage transaction = transactions[transactionId];
        require(transaction.transactionData.proposer != address(0), "Transaction not found");
        require(!transaction.approvals[msg.sender], "Already approved");

        transaction.approvals[msg.sender] = true;
        transaction.approvalCount++;

        emit TransactionApproved(actionId, msg.sender);

        if (transaction.approvalCount >= requiredSignatures) {
            (bool success, ) = address(this).call(transaction.transactionData.data);
            require(success, "Transaction execution failed");
            emit TransactionExecuted(actionId);
        }
    }
}

// EcoWattCoin.sol: Main contract implementing ERC20 with Ownable, ReentrancyGuard, Pausable, Timelock, RoleBasedAccessControl, and MultisigVault.
contract EcoWattCoin is ERC20, Ownable, ReentrancyGuard, Pausable, Timelock, RoleBasedAccessControl, MultisigVault {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 1000000000 * 10**18;
    uint256 private constant INITIAL_SUPPLY = 10000000 * 10**18;
    address private constant ZERO_ADDRESS = address(0);

    uint256 private _actionCounter;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event UnexpectedEtherReceived(address sender, uint256 amount);

    struct MintAction {
        address to;
        uint256 amount;
        uint256 timestamp;
    }

    struct BurnAction {
        address from;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(bytes32 => MintAction) private _mintActions;
    mapping(bytes32 => BurnAction) private _burnActions;

    /**
     * @dev Initializes the contract by minting the initial supply to the deployer.
     */
    constructor(address[] memory signatories, uint256 requiredSignatures, address initialOwner)
        ERC20()
        Ownable(initialOwner)
        MultisigVault(signatories, requiredSignatures)
    {
        require(INITIAL_SUPPLY <= MAX_SUPPLY, "Initial supply exceeds max supply");
        _mint(initialOwner, INITIAL_SUPPLY);
    }

    /**
     * @dev Transfers `amount` tokens to `recipient`, with non-reentrancy and when not paused checks.
     */
    function transfer(address recipient, uint256 amount) public virtual override nonReentrant whenNotPaused returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        return super.transfer(recipient, amount);
    }

    /**
     * @dev Transfers `amount` tokens from `sender` to `recipient`, with non-reentrancy and when not paused checks.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override nonReentrant whenNotPaused returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        return super.transferFrom(sender, recipient, amount);
    }

    /**
     * @dev Queues a mint action to be executed after the delay.
     */
    function queueMint(address to, uint256 amount) public onlyOwnerOrSecondary onlyMinter {
        require(to != ZERO_ADDRESS, "ERC20: mint to the zero address");
        require(amount > 0, "ERC20: mint amount must be greater than zero");
        require(totalSupply().add(amount) <= MAX_SUPPLY, "ERC20: minting exceeds max supply");

        uint256 timestamp = block.timestamp;
        bytes32 actionId = keccak256(abi.encodePacked("mint", to, amount, timestamp, _actionCounter++));
        _mintActions[actionId] = MintAction(to, amount, timestamp);
        queueAction(actionId);
    }

    /**
     * @dev Executes a queued mint action after the delay.
     */
    function executeMint(bytes32 actionId) public onlyOwnerOrSecondary timelocked(actionId) {
        MintAction memory action = _mintActions[actionId];
        require(action.to != ZERO_ADDRESS, "ERC20: mint to the zero address");
        require(action.amount > 0, "ERC20: mint amount must be greater than zero");
        require(totalSupply().add(action.amount) <= MAX_SUPPLY, "ERC20: minting exceeds max supply");

        _mint(action.to, action.amount);
        emit Mint(action.to, action.amount);
        delete _mintActions[actionId];
    }

    /**
     * @dev Queues a burn action to be executed after the delay.
     */
    function queueBurn(address from, uint256 amount) public onlyOwnerOrSecondary onlyBurner {
        require(from != ZERO_ADDRESS, "ERC20: burn from the zero address");
        require(balanceOf(from) >= amount, "ERC20: burn amount exceeds balance");
        require(amount > 0, "ERC20: burn amount must be greater than zero");

        uint256 timestamp = block.timestamp;
        bytes32 actionId = keccak256(abi.encodePacked("burn", from, amount, timestamp, _actionCounter++));
        _burnActions[actionId] = BurnAction(from, amount, timestamp);
        queueAction(actionId);
    }

    /**
     * @dev Executes a queued burn action after the delay.
     */
    function executeBurn(bytes32 actionId) public onlyOwnerOrSecondary timelocked(actionId) {
        BurnAction memory action = _burnActions[actionId];
        require(action.from != ZERO_ADDRESS, "ERC20: burn from the zero address");
        require(action.amount > 0, "ERC20: burn amount must be greater than zero");
        require(balanceOf(action.from) >= action.amount, "ERC20: burn amount exceeds balance");

        _burn(action.from, action.amount);
        emit Burn(action.from, action.amount);
        delete _burnActions[actionId];
    }

    /**
     * @dev Cancels a queued mint action.
     */
    function cancelMint(bytes32 actionId) public onlyOwnerOrSecondary {
        require(_mintActions[actionId].to != address(0), "ERC20: mint action not found");
        delete _mintActions[actionId];
        cancelAction(actionId);
    }

    /**
     * @dev Cancels a queued burn action.
     */
    function cancelBurn(bytes32 actionId) public onlyOwnerOrSecondary {
        require(_burnActions[actionId].from != address(0), "ERC20: burn action not found");
        delete _burnActions[actionId];
        cancelAction(actionId);
    }

    /**
     * @dev Pauses the contract.
     */
    function pause() public onlyOwnerOrSecondary {
        _pause();
    }

    /**
     * @dev Unpauses the contract.
     */
    function unpause() public onlyOwnerOrSecondary {
        _unpause();
    }

    /**
     * @dev Reverts any Ether sent to the contract.
     */
    fallback() external payable {
        revert("Fallback: unexpected transfer received");
    }

    /**
     * @dev Reverts any Ether sent to the contract.
     */
    receive() external payable {
        revert("Receive: ETH not accepted");
    }
}
