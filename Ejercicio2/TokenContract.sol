// SPDX-License-Identifier: Unlicenced

pragma solidity ^0.8.18;

contract TokenContract {
    address public owner;
    struct Receivers {
        string name;
        uint256 tokens;
    }

    mapping(address => Receivers) public users;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint){
        return _value*2;
    }

    function register(string memory _name) public{
        users[msg.sender].name = _name;
    }

    function giveToken(address _receiver, uint256 _amount) onlyOwner public{
        require(users[owner].tokens >= _amount);
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }
    // Definimos un evento para "imprimir" el valor
    //event DebugValor(uint256 nuevoValor);

    function comprarToken(address _receiver, uint256 _amount) public payable{
        uint256 tokenvalue = 5 ether;
        uint256 tokensrequeridos = _amount/tokenvalue;

        
        //emit DebugValor(tokensrequeridos);
        
        require(tokensrequeridos >= 1, "No es suficiente para comprar un token");
        require(users[owner].tokens >= tokensrequeridos, "No hay tokens disponibles");

        giveToken(_receiver, tokensrequeridos);
        getBalance(_receiver);
    }

    function getBalance(address _receiver) public view returns (uint256){
        return _receiver.balance;
    }


 }