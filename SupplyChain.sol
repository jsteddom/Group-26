pragma solidity ^0.8.0;
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
    
    // Counters for unique IDs
    Counters.Counter private _productIdCounter;
    Counters.Counter private _materialIdCounter;
    Counters.Counter private _batchIdCounter;
    Counters.Counter private _batchIdCounter;


Here’s the same program with comments rewritten the way a rushed student might type them, with uneven spacing, run-ons, and mismatched paragraph spacing (code untouched).

// ----------------------------------------
// MAPPINGS
// ----------------------------------------

// so this is like where we keep raw stuff, basically id => RawMaterial lol
mapping(uint256 => RawMaterial) public rawMaterials;

// products map here, product id to Product, kinda obvious but yeah
mapping(uint256 => Product) public products;

// history for each product, an array cuz multiple events happen over time  ok
mapping(uint256 => SupplyChainEvent[]) public productHistory;

// stakeholders by address. active flag inside struct decides if they’re real
mapping(address => Stakeholder) public stakeholders;

// batchNumber => list of product ids. helps to query a whole batch at once (nice for recalls)
mapping(string => uint256[]) public batchProducts;

// ----------------------------------------
// EVENTS
// ----------------------------------------

/*
   fires when someone new joins. admin does it usually but anyway this tells frontends
*/
event StakeholderRegistered(
    address indexed stakeholderAddress,
    string name,
    string role,
    uint256 timestamp
);

/*
  new raw material added event —— used by UI to show stuff in activity feed
  keeps track of which manufacturer provided which material at what time.
*/
event RawMaterialAdded(
    uint256 indexed materialId,
    string name,
    address indexed manufacturer,
    uint256 timestamp
);

/*
    regulator clicks verify or w/e and then this happens.
    keeps the record of certification for raw material. If a batch of product has quality issues this can help find the cause.
*/
event RawMaterialVerified(
    uint256 indexed materialId,
    address indexed verifier,
    uint256 timestamp
);

/*
 product made in factory. batchNumber is like link to others from same run
 vital for holding record of drugs that are in the market.
*/
event ProductManufactured(
    uint256 indexed productId,
    string name,
    string batchNumber,
    address indexed manufacturer,
    uint256 timestamp
);

/*
   transfer event. from -> to. updates status helping keep track of chain of custody for the product
*/
event ProductTransferred(
    uint256 indexed productId,
    address indexed from,
    address indexed to,
    ProductStatus newStatus,
    uint256 timestamp
);

/*
  when something goes wrong or we need to yank it from market.
  the product id here will be used with mapping of batch products to quickly get which products need to be recalled.
  furthermore the raw material verification can help quickly segregate between raw material quality issues and manufacturing issues.
*/
event ProductRecalled(
    uint256 indexed productId,
    string reason,
    address indexed initiator,
    uint256 timestamp
);

/*
 log arbitrary events like QC pass/fail or temperature alerts during shipping etc
*/
event SupplyChainEventLogged(
    uint256 indexed productId,
    string eventType,
    address indexed actor,
    uint256 timestamp
);

// ----------------------------------------
// MODIFIERS
// ----------------------------------------

/*
    only let actual registered ppl call. otherwise nope. saves us headaches later
*/
modifier onlyRegisteredStakeholder() {
    require(stakeholders[msg.sender].isActive, "Caller is not a registered stakeholder");
    _;
}

/*
   check product is real. if id >= counter it means not minted yet
   _productId is the thing we test. yes this is a little confusing at first
*/
modifier productExists(uint256 _productId) {
    require(_productId < _productIdCounter.current(), "Product does not exist");
    _;
}

/*
   similar check but for raw materials. again comparing against counter
   _materialId must be valid or we revert
*/
modifier materialExists(uint256 _materialId) {
    require(_materialId < _materialIdCounter.current(), "Material does not exist");
    _;
}

// ----------------------------------------
// CONSTRUCTOR
// ----------------------------------------

/*
  give admin and regulator to deployer for now. later can delegate properly if needed
*/
constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(REGULATOR_ROLE, msg.sender);
}

// ----------------------------------------
// STAKEHOLDER MANAGEMENT FUNCTIONS
// ----------------------------------------

/*
  register a company/person in the network. admin only. 
  we store name, role, licenseNumber etc so later checks make sense
*/
function registerStakeholder(
    address _address,
    string memory _name,
    string memory _role,
    string memory _licenseNumber
) external onlyRole(DEFAULT_ADMIN_ROLE) {
    // Function implementation will be added
}

/*
   give extra permissions to an address. like MANUFACTURER_ROLE, etc.
   admin does this. careful who gets what lol
*/
function grantStakeholderRole(address _stakeholder, bytes32 _role) 
    external 
    onlyRole(DEFAULT_ADMIN_ROLE) 
{
    // Function implementation will be added
}

/*
   deactivates them (like soft delete). still in mapping but marked inactive
   admin only cuz security
*/
function deactivateStakeholder(address _address) 
    external 
    onlyRole(DEFAULT_ADMIN_ROLE) 
{
    // Function implementation will be added
}

// ----------------------------------------
// RAW MATERIAL MANAGEMENT FUNCTIONS
// ----------------------------------------

/*
  add new raw material by a manufacturer. 
  includes origin + certification hash (ipfs probably) and expiry. returns id
*/
function addRawMaterial(
    string memory _name,
    string memory _origin,
    string memory _certificationHash,
    uint256 _quantity,
    uint256 _expiryDate
) external onlyRole(MANUFACTURER_ROLE) returns (uint256) {
    // Function implementation will be added
}

/*
  regulator verifies a material so it can be used in products. 
  basically sets a flag and emits event so everyone trusts it
*/
function verifyRawMaterial(uint256 _materialId) 
    external 
    onlyRole(REGULATOR_ROLE) 
    materialExists(_materialId) 
{
    // Function implementation will be added
}

/*
  fetch one material details back. cheap view call
*/
function getRawMaterial(uint256 _materialId) 
    external 
    view 
    materialExists(_materialId) 
    returns (RawMaterial memory) 
{
    // Function implementation will be added
}

// ----------------------------------------
// PRODUCT MANAGEMENT FUNCTIONS
// ----------------------------------------

/*
  create a product. needs materials to already be verified otherwise nope. 
  sets batchNumber and expiry so downstream can track for recalls
*/
function manufactureProduct(
    string memory _name,
    string memory _batchNumber,
    uint256[] memory _materialIds,
    uint256 _expiryDate
) external onlyRole(MANUFACTURER_ROLE) returns (uint256) {
    // Function implementation will be added in the future
}

/*
  hand over product to next actor in chain. updates status, owner, and location.
  only current owner allowed to do this, duh
*/
function transferProduct(
    uint256 _productId,
    address _to,
    ProductStatus _newStatus,
    string memory _location
) external onlyRegisteredStakeholder productExists(_productId) nonReentrant {
    // Function implementation will be added
}

/*
  sometimes status changes without transfer (like QC fail). 
  owner or regulator can do it, add notes for audit
*/
function updateProductStatus(
    uint256 _productId,
    ProductStatus _newStatus,
    string memory _notes
) external onlyRegisteredStakeholder productExists(_productId) {
    // Function implementation will be added
}

/*
   recall the product for safety. manuf or regulator can trigger. reason string explains why
*/
function recallProduct(uint256 _productId, string memory _reason) 
    external 
    productExists(_productId) 
{
    // Function implementation will be added
}

/*
  read-only getter for product full struct, handy in UI
*/
function getProduct(uint256 _productId) 
    external 
    view 
    productExists(_productId) 
    returns (Product memory) 
{
    // Function implementation will be added
}

// ----------------------------------------
// TRACEABILITY AND AUDIT FUNCTIONS
// ----------------------------------------

/*
  log any event about the product, like storage temp spike or passed quality test.
  only registered folks can do this cuz we need accountability
*/
function logSupplyChainEvent(
    uint256 _productId,
    string memory _eventType,
    string memory _location,
    string memory _notes
) external onlyRegisteredStakeholder productExists(_productId) {
    // Function implementation will be added
}

/*
  return the chronological list of events for a product. 
  basically the audit trail everyone talks about
*/
function getProductHistory(uint256 _productId) 
    external 
    view 
    productExists(_productId) 
    returns (SupplyChainEvent[] memory) 
{
    // Function implementation will be added
}

/*
  get all product ids from same batch number. useful for queries + recalls
*/
function getBatchProducts(string memory _batchNumber) 
    external 
    view 
    returns (uint256[] memory) 
{
    // Function implementation will be added
}

/*
  try to verify if a product is real by walking provenance etc. 
  returns boolean and some details string to show in UI
*/
function verifyProductAuthenticity(uint256 _productId) 
    external 
    view 
    productExists(_productId) 
    returns (bool isAuthentic, string memory details) 
{
    // Function implementation will be added
}

/*
  list all products that a manufacturer created. mostly for dashboards
*/
function getProductsByManufacturer(address _manufacturer) 
    external 
    view 
    returns (uint256[] memory) 
{
    // Function implementation will be added
}

// ----------------------------------------
// UTILITY FUNCTIONS
// ----------------------------------------

/*
  how many total products so far. just returns counter
*/
function getTotalProducts() external view returns (uint256) {
    return _productIdCounter.current();
}

/*
  how many raw materials exist rn. counter again
*/
function getTotalMaterials() external view returns (uint256) {
    return _materialIdCounter.current();
}

/*
  quick check if an address is registered+active stakeholder. true/false
*/
function isRegisteredStakeholder(address _address) external view returns (bool) {
    return stakeholders[_address].isActive;
}
