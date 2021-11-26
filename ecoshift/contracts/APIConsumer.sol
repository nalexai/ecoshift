// SPDX-License-Identifier: MIT

pragma solidity >=0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
    @dev APIConsumer makes a simple Chainlink request to get addresses 
    @dev job type is `GET uint256`, which is cast to an address
 */

contract APIConsumer is ChainlinkClient {
    using Chainlink for Chainlink.Request;
  
    address public gotAddress; // store the address recieved
    bytes32 public resp;
    string public resp_str;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    
    /**
      @param _oracle The chainlink oracle address
      @param _jobId The id for `GET uint256` job
      @param _fee The chainlink fee
      @param _link The address of LINK token contract
    */
    constructor(address _oracle, bytes32 _jobId, uint256 _fee, address _link) {
        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
    }
    
    /**
     * Create a Chainlink request to retrieve uint256 API response
     * @dev currently requests from a static address placeholder; in reality it would update
     */
    function requestData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        request.add("get", "https://ipfs.io/ipfs/bafkreiacp73dnke22k72kpymqenlz5fehjbjpxanquceomtwowla26wsbu");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    function getFee() public view returns (uint256) {
        return fee;
    }
    
    /**
     * Recieve uint256 from chainlink oracle
     * @dev stores response in `gotAddress` after casting
     */ 
    function fulfill(bytes32 _requestId, uint256 _address) public recordChainlinkFulfillment(_requestId)
    {
        gotAddress = address(uint160(_address));
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
