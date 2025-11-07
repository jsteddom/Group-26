pragma solidity ^0.8.0;
/**
  @title PharmaSupplyChain
  @dev Main smart contract for managing pharmaceutical supply chain provenance
  @notice This contract tracks pharmaceutical products and raw materials from manufacturers to end consumers
  
  Key Features:
  - Immutable record keeping for products and raw materials
  - Role-based access control for different stakeholders
  - Event logging for complete traceability
  - Product provenance verification
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
