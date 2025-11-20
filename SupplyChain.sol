pragma solidity ^0.8.20;

/**
 @group 26
 @title PharmaSupplyChain
 @dev this is the main smart contract that we made for handling the pharma supply chain provenance. 
 it basically keeps track of the products and raw materials as they move around.  

 the idea is to make sure we can see where stuff came from and who had it before. 
 it’s about transparency and making sure the medicine is authentic.  
*/

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title PharmaSupplyChain
 * @dev Manages pharmaceutical product provenance with role-based access.
 */
contract PharmaSupplyChain is AccessControl, ReentrancyGuard {
    using Counters for Counters.Counter;

   
    // ----------------------------------------
    // STATE VARIABLES
    // ----------------------------------------
    
    // Role definitions for access control

    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant PHARMACIST_ROLE = keccak256("PHARMACIST_ROLE");
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");

    // Counters for unique IDs, have reduced the number of counters 
    //from initial submission
    Counters.Counter private _productIdCounter;
    Counters.Counter private _materialIdCounter;

     // ============================================
    // DATA STRUCTURES
    // ============================================
    // small note for this section

    // Enum that represents where the product is in the supply chain
    enum ProductStatus { Manufactured, InTransit, AtDistributor, AtPharmacy, Sold, Recalled }
    
    // Struct for raw material and details regarding the raw material
    // such as the name, manufacturer and verified status
    struct RawMaterial {
        uint256 id;
        string name;
        address manufacturer;
        uint256 quantity;
        bool isVerified;
    }

    // Struct for product and details regarding the prodcut
    // such as the name, manufacturer and manufactured date
    struct Product {
        uint256 id;
        string name;
        string batchNumber;
        address manufacturer;
        address currentOwner;
        uint256[] materialIds;
        ProductStatus status;
        bool isRecalled;
    }
    
    // Struct to represent the stakeholder and credentials
    struct Stakeholder {
        address addr;
        string name;
        string role;
        bool isActive;
    }

    // --- Mappings ---
    mapping(uint256 => RawMaterial) public rawMaterials;
    mapping(uint256 => Product) public products;
    mapping(address => Stakeholder) public stakeholders;

    // --- Events ---
    event StakeholderRegistered(address indexed stakeholderAddress, string name, string role);
    event RawMaterialAdded(uint256 indexed materialId, string name, address indexed manufacturer);
    event RawMaterialVerified(uint256 indexed materialId, address indexed verifier);
    event ProductManufactured(uint256 indexed productId, string name, address indexed manufacturer);
    event ProductTransferred(uint256 indexed productId, address indexed from, address indexed to, ProductStatus newStatus);
    event ProductRecalled(uint256 indexed productId, string reason, address indexed initiator);

    // --- Constructor ---
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REGULATOR_ROLE, msg.sender); // Admin is also a regulator
        stakeholders[msg.sender] = Stakeholder(msg.sender, "Contract Admin", "ADMIN", true);
        emit StakeholderRegistered(msg.sender, "Contract Admin", "ADMIN");
    }

    // --- Stakeholder Functions ---
    function registerStakeholder(address _addr, string memory _name, string memory _role, bytes32 _roleByte) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!stakeholders[_addr].isActive, "Stakeholder already registered.");
        stakeholders[_addr] = Stakeholder(_addr, _name, _role, true);
        _grantRole(_roleByte, _addr);
        emit StakeholderRegistered(_addr, _name, _role);
    }

    // --- Material Functions ---
    function addRawMaterial(string memory _name, uint256 _quantity) external onlyRole(MANUFACTURER_ROLE) {
        _materialIdCounter.increment();
        uint256 newId = _materialIdCounter.current();
        rawMaterials[newId] = RawMaterial(newId, _name, msg.sender, _quantity, false);
        emit RawMaterialAdded(newId, _name, msg.sender);
    }

    function verifyRawMaterial(uint256 _materialId) external onlyRole(REGULATOR_ROLE) {
        require(rawMaterials[_materialId].id != 0, "Material does not exist.");
        rawMaterials[_materialId].isVerified = true;
        emit RawMaterialVerified(_materialId, msg.sender);
    }

    // --- Product Functions ---
    function manufactureProduct(string memory _name, string memory _batch, uint256[] memory _materialIds) external onlyRole(MANUFACTURER_ROLE) {
        // Check if all materials are verified
        for (uint i = 0; i < _materialIds.length; i++) {
            require(rawMaterials[_materialIds[i]].isVerified, "Material not verified.");
        }

        _productIdCounter.increment();
        uint256 newId = _productIdCounter.current();
        products[newId] = Product(newId, _name, _batch, msg.sender, msg.sender, _materialIds, ProductStatus.Manufactured, false);
        emit ProductManufactured(newId, _name, msg.sender);
    }

    function transferProduct(uint256 _productId, address _to) external nonReentrant {
        Product storage product = products[_productId];
        require(product.id != 0, "Product does not exist.");
        require(product.currentOwner == msg.sender, "Only owner can transfer.");
        require(!product.isRecalled, "Product has been recalled.");

        ProductStatus newStatus;
        if (hasRole(DISTRIBUTOR_ROLE, _to)) {
            newStatus = ProductStatus.AtDistributor;
        } else if (hasRole(PHARMACIST_ROLE, _to)) {
            newStatus = ProductStatus.AtPharmacy;
        } else {
            revert("Invalid recipient role.");
        }

        product.currentOwner = _to;
        product.status = newStatus;
        emit ProductTransferred(_productId, msg.sender, _to, newStatus);
    }
    
    function sellProduct(uint256 _productId) external onlyRole(PHARMACIST_ROLE) {
        Product storage product = products[_productId];
        require(product.currentOwner == msg.sender, "Not the owner.");
        product.status = ProductStatus.Sold;
        emit ProductTransferred(_productId, msg.sender, address(0), ProductStatus.Sold);
    }

    function recallProduct(uint256 _productId, string memory _reason) external {
        require(hasRole(MANUFACTURER_ROLE, msg.sender) || hasRole(REGULATOR_ROLE, msg.sender), "Not authorized to recall.");
        Product storage product = products[_productId];
        require(product.manufacturer == msg.sender || hasRole(REGULATOR_ROLE, msg.sender), "Only original manufacturer or regulator can recall.");
        product.isRecalled = true;
        product.status = ProductStatus.Recalled;
        emit ProductRecalled(_productId, _reason, msg.sender);
    }

    // --- View Functions ---
    function getProduct(uint256 _productId) external view returns (Product memory) {
        return products[_productId];
    }

    function getRawMaterial(uint256 _materialId) external view returns (RawMaterial memory) {
        return rawMaterials[_materialId];
    }

    function supportsInterface(bytes4 interfaceId) public view override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

