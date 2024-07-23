// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    string private constant TOKEN_NAME = "EcoWattCoin";
    string private constant TOKEN_SYMBOL = "EWTC"; // Alterado para EWTC
    uint256 public constant MAX_SUPPLY = 1000000000 * 10**18; // Definido aqui

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

abstract contract Ownable is Context {
    address private _owner;
    address private _secondaryOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecondaryOwnerSet(address indexed previousSecondaryOwner, address indexed newSecondaryOwner);

    constructor(address initialOwner) {
        require(initialOwner != address(0), "Ownable: initial owner is the zero address");
        _transferOwnership(initialOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function secondaryOwner() public view virtual returns (address) {
        return _secondaryOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOwnerOrSecondary() {
        require(_msgSender() == owner() || _msgSender() == _secondaryOwner, "Ownable: caller is not the owner or secondary owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(newOwner != _msgSender(), "Ownable: new owner is the same as current owner");
        _transferOwnership(newOwner);
    }

    function setSecondaryOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new secondary owner is the zero address");
        require(newOwner != owner(), "Ownable: new secondary owner is the same as the current owner");
        require(newOwner != _secondaryOwner, "Ownable: new secondary owner is the same as the current secondary owner");
        emit SecondaryOwnerSet(_secondaryOwner, newOwner);
        _secondaryOwner = newOwner;
    }

    function revokeSecondaryOwner() public onlyOwner {
        require(_secondaryOwner != address(0), "Ownable: secondary owner is not set");
        emit SecondaryOwnerSet(_secondaryOwner, address(0));
        _secondaryOwner = address(0);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract Timelock {
    using SafeMath for uint256;

    uint256 private constant _DELAY = 1 minutes;
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

abstract contract RoleBasedAccessControl is Context {
    mapping(address => bool) private _minters;
    mapping(address => bool) private _burners;
    mapping(address => bool) private _admins;
    uint256 private _adminCount;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);
    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

    constructor() {
        _admins[_msgSender()] = true;
        _adminCount = 1;
    }

    modifier onlyAdmin() {
        require(isAdmin(_msgSender()), "RoleBasedAccessControl: caller is not an admin");
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

    function addAdmin(address account) public onlyAdmin {
        require(account != address(0), "RoleBasedAccessControl: admin is the zero address");
        require(!isAdmin(account), "RoleBasedAccessControl: account is already an admin");
        _admins[account] = true;
        _adminCount++;
        emit AdminAdded(account);
    }

    function removeAdmin(address account) public onlyAdmin {
        require(isAdmin(account), "RoleBasedAccessControl: account is not an admin");
        require(_adminCount > 1, "RoleBasedAccessControl: cannot remove the last admin");
        _admins[account] = false;
        _adminCount--;
        emit AdminRemoved(account);
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins[account];
    }
}

contract EcoWattCoin is ERC20, Ownable, ReentrancyGuard, Pausable, Timelock, RoleBasedAccessControl {
    using SafeMath for uint256;

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
    constructor(address initialOwner) ERC20() Ownable(initialOwner) {
        require(INITIAL_SUPPLY <= MAX_SUPPLY, "Initial supply exceeds max supply");
        _mint(initialOwner, INITIAL_SUPPLY);
    }

    /**
     * @dev Transfers `amount` tokens to `recipient`, with non-reentrancy and when not paused checks.
     */
    function transfer(address recipient, uint256 amount) public virtual override nonReentrant whenNotPaused returns (bool) {
        return super.transfer(recipient, amount);
    }

    /**
     * @dev Transfers `amount` tokens from `sender` to `recipient`, with non-reentrancy and when not paused checks.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override nonReentrant whenNotPaused returns (bool) {
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
