//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

contract FabricaContract {
    uint idDigits = 16;
    struct Producto {
        string nombre;
        uint id;
    }

    Producto[] productos;

    function _crearProducto(string memory _nombre, uint _id) private {
        productos.push(Producto(_nombre,_id));
        emit NuevoProducto(productos.length-1, _nombre, _id);
    }

    function _generarIdAleatorio(string memory _str) private view returns(uint){
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        uint idModulus = 10^idDigits;
        return rand % idModulus;
    }

    function crearProductoAleatorio(string memory _nombre) public {
        uint _randId = _generarIdAleatorio(_nombre);
        _crearProducto(_nombre, _randId);
    }

    event NuevoProducto(uint ArrayProductoId, string nombre, uint id);

    mapping (uint => address) public productoAPropietario;
    mapping (address => uint) public propietarioProductos;

    function Propiedad(uint _productoId) public {
        productoAPropietario[_productoId] = msg.sender;
        propietarioProductos[msg.sender] += 1;
    }

    function getProductosPorPropietario(address _propietario) view external returns (uint[] memory) {
        uint contador = 0;
        uint[] memory resultado = new uint[](propietarioProductos[_propietario]);
    
    // Recorremos todos los productos
    for (uint i = 0; i < productos.length; i++) { 
        if (productoAPropietario[i] == _propietario) {
            resultado[contador] = i;
            contador++;
        }
    }
        return resultado;
    }
}