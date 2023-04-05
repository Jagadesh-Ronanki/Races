// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "openzeppelin-contracts/contracts/utils/Context.sol";

  contract InSecureum is Context, IERC20, IERC20Metadata {
      mapping(address => uint256) private _balances; // tracks balances of users X -> Amount
      mapping(address => mapping(address => uint256)) private _allowances; // tracks allowances X -> Y -> amount
      uint256 private _totalSupply;
      // @audit `immutable` saves gas?
      string private _name;
      string private _symbol;

  constructor(string memory name_, string memory symbol_) {
      _name = name_;
      _symbol = symbol_;
  }

  function name() public view virtual override returns (string memory) {
      return _name;
  }

  function symbol() public view virtual override returns (string memory) {
      return _symbol;
  }

  function decimals() public view virtual override returns (uint8) { //@audit `pure`
      return 8;
  }

  function totalSupply() public view virtual override returns (uint256) {
      return _totalSupply;
  }

  function balanceOf(address account)
      public
      view
      virtual
      override
      returns (uint256)
  {
      return _balances[account];
  }

  function transfer(address recipient, uint256 amount)
      public
      virtual
      override
      returns (bool)
  {
      _transfer(_msgSender(), recipient, amount); // can we call it multiple times?
      return true;
  }

  function allowance(address owner, address spender)
      public
      view
      virtual
      override
      returns (uint256)
  {
      return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
      public
      virtual
      override
      returns (bool)
  {
      // @audit can approve more money to spender than the msgSender owned?
      _approve(_msgSender(), spender, amount); 
      return true;
  }

  function transferFrom(
      address sender,
      address recipient,
      uint256 amount
  ) public virtual override returns (bool) { // what is this function doing?
      uint256 currentAllowance = _allowances[_msgSender()][sender];
      if (currentAllowance != type(uint256).max) {
          unchecked {
              _approve(sender, _msgSender(), currentAllowance - amount);
          }
      }
      // @audit anybody can act behalf of sender 
      // :no check for the msg.sender own the approval of sending money in _transfer function:
      _transfer(sender, recipient, amount);
      return true;
  }

  // @audit is the allowance added twice
  // :_approve function adds the balance to current amount:
  function increaseAllowance(address spender, uint256 addedValue)
      public
      virtual
      returns (bool)
  {
      _approve(
          _msgSender(),
          spender,
          _allowances[_msgSender()][spender] + addedValue
      );
      return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
      public
      virtual
      returns (bool)
  {
      uint256 currentAllowance = _allowances[_msgSender()][spender];
      require(
          currentAllowance > subtractedValue,
          "ERC20: decreased allowance below zero"
      );
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
      return true;
  }

  function _transfer(
      address sender,
      address recipient,
      uint256 amount
  ) internal virtual { // no check if sender == msg.sender or msg.sender allowance for transfering money 
      require(sender != address(0), "ERC20: transfer from the zero address");
      require(recipient != address(0), "ERC20: transfer to the zero address");
      uint256 senderBalance = _balances[sender];
      require(
          senderBalance >= amount,
          "ERC20: transfer amount exceeds balance"
      );
      unchecked {
          _balances[sender] = senderBalance - amount;
      }
      _balances[recipient] += amount; //@audit gas tip
      emit Transfer(sender, recipient, amount);
  }

  // @audit minting to same address twice 
  // result in loosing the tokens?
  // 0 address check missing
  function _mint(address account, uint256 amount) external virtual {
      _totalSupply += amount;
      _balances[account] = amount;
      emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
      require(account != address(0), "ERC20: burn from the zero address");
      require(
          _balances[account] >= amount,
          "ERC20: burn amount exceeds balance"
      );
      unchecked {
          _balances[account] = _balances[account] - amount;
      }
      _totalSupply -= amount;
      emit Transfer(address(0), account, amount);
  }

  function _approve(
      address owner,
      address spender,
      uint256 amount
  ) internal virtual { // not checking owners account balance can lead to over money allowance?
      require(spender != address(0), "ERC20: approve from the zero address");
      require(owner != address(0), "ERC20: approve to the zero address");
      _allowances[owner][spender] += amount; //@audit gas tip
      emit Approval(owner, spender, amount);
  }
}
