// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MiBazar is ERC721, Ownable {

    IERC20 public token; // Token ERC20 usado para pagos

    struct Skin{
        string nombre;
        string id_usuario;
        uint id;
        uint precio_compra;
        uint precio_alquiler;
        uint hora_de_compra; // Cuando fue comprada una skin
        uint tiempo_de_alquiler; // Cuantos días está alquilada
    }

    mapping(uint => Skin) public almacenSkins;
    mapping(string => address) public usuarios;

    uint public idSkin;


    constructor(string memory _name, string memory _symbol, address _tokenAddress) ERC721(_name, _symbol) Ownable(msg.sender) {
        idSkin = 0; 
        token = IERC20(_tokenAddress);
    }

    function registrarUsuario(string memory _id_usuario) public {
        require(usuarios[_id_usuario] == address(0), "El usuario ya esta registrado");
        usuarios[_id_usuario] = msg.sender; 
    }

    function _crearSkin(string memory _nombre, uint _precio_compra, uint _precio_alquiler) external {
        almacenSkins[idSkin] = Skin(_nombre, "null", idSkin, _precio_compra, _precio_alquiler, 0, 0);
        idSkin++;
    }

    function _datosSkin(uint _id) public view returns (Skin memory) {
        require(_id < idSkin, "El producto no existe");
        return almacenSkins[_id];
    }

    function eliminarSkin(uint _id) public {
        require(_id < idSkin, "El producto no existe");
        
        string memory estado = _devuelveEstado(_id);
        require(keccak256(abi.encodePacked(estado)) != keccak256(abi.encodePacked("Comprada")), "La skin no puede ser eliminada porque ya fue comprada");
        require(keccak256(abi.encodePacked(estado)) != keccak256(abi.encodePacked("Alquilada")), "La skin no puede ser eliminada porque ya fue alquilada");
        
        delete almacenSkins[_id];
    }

    function _devuelveEstado(uint _id) public view returns (string memory) {
        require(_id < idSkin, "El producto no existe"); 

        if (block.timestamp > _datosSkin(_id).tiempo_de_alquiler){
            _datosSkin(_id).hora_de_compra = 0;
            _datosSkin(_id).tiempo_de_alquiler = 0;
        }

        if (_datosSkin(_id).hora_de_compra == 0) {
            return "Disponible";
        }else {
            if(_datosSkin(_id).tiempo_de_alquiler == 0) {
                return "Comprada";
            }else{
                return "Alquilada";
            }
        }
    }


    function _comprarSkin(uint _id, string memory _id_usuario) public payable {
        require(_id < idSkin, "El producto no existe");
        
        Skin storage skin = almacenSkins[_id];
        string memory estado = _devuelveEstado(_id);
        require(keccak256(abi.encodePacked(estado)) == keccak256(abi.encodePacked("Disponible")), "La skin no esta disponible para compra");
        
        require(usuarios[_id_usuario] == msg.sender, "El usuario no esta registrado o no corresponde a la direccion");

         require(token.transferFrom(msg.sender, owner(), skin.precio_compra), "Fallo la transferencia del token ERC20");

        skin.id_usuario = _id_usuario;
        skin.hora_de_compra = block.timestamp; 
        skin.tiempo_de_alquiler = 0;

       // payable(owner()).transfer(msg.value);
    }

    function alquilarSkin(uint _id, string memory _id_usuario, uint _dias) public payable {
        require(_id < idSkin, "El producto no existe");
        require(_dias > 0, "La duracion del alquiler debe ser mayor a 0");
    

        Skin storage skin = almacenSkins[_id];
        string memory estado = _devuelveEstado(_id);
 
        require(keccak256(abi.encodePacked(estado)) == keccak256(abi.encodePacked("Disponible")), "La skin no esta disponible para alquiler");

        require(usuarios[_id_usuario] == msg.sender, "El usuario no esta registrado o no corresponde a la direccion");

        uint costoAlquiler = skin.precio_alquiler * _dias;

        require(token.transferFrom(msg.sender, owner(), costoAlquiler), "Fallo la transferencia del token ERC20");


        skin.id_usuario = _id_usuario;
        skin.hora_de_compra = block.timestamp;
        skin.tiempo_de_alquiler = block.timestamp + (_dias * 1 days);

       // payable(owner()).transfer(msg.value);

    }


}