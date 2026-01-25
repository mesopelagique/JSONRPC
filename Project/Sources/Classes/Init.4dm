// JSON-RPC utilities singleton
// Factory methods and parsing for JSON-RPC messages

// ============================================================================
// Error codes (constants)
// ============================================================================

property URL_ELICITATION_REQUIRED : Integer:=-32042

// SDK error codes
property CONNECTION_CLOSED : Integer:=-32000
property REQUEST_TIMEOUT : Integer:=-32001

// Standard JSON-RPC error codes
property PARSE_ERROR : Integer:=-32700
property INVALID_REQUEST : Integer:=-32600
property METHOD_NOT_FOUND : Integer:=-32601
property INVALID_PARAMS : Integer:=-32602
property INTERNAL_ERROR : Integer:=-32603

shared singleton Class constructor
	
	// ============================================================================
	// Factory methods for creating messages
	// ============================================================================
	
Function request($method : Text; $params : Object) : cs:C1710.Request
	return cs:C1710.Request.new($method; $params)
	
Function notification($method : Text; $params : Object) : cs:C1710.Notification
	return cs:C1710.Notification.new($method; $params)
	
Function response($id : Variant; $result : Object) : cs:C1710.Response
	return cs:C1710.Response.new($id; $result)
	
Function error($id : Variant; $code : Integer; $message : Text; $data : Variant) : cs:C1710.Error
	var $errorData : cs:C1710.ErrorData:=cs:C1710.ErrorData.new($code; $message; $data)
	return cs:C1710.Error.new($id; $errorData)
	
Function errorData($code : Integer; $message : Text; $data : Variant) : cs:C1710.ErrorData
	return cs:C1710.ErrorData.new($code; $message; $data)
	
	// ============================================================================
	// Parsing methods
	// ============================================================================

	// Parse a JSON string, object, or collection into the appropriate JSON-RPC type(s)
	// Returns an object with .type and .value properties
	// For batch requests (collections), returns {type: "batch"; value: <collection of parsed messages>}
Function parse($input : Variant) : Object
	var $parsed : Variant

	// Handle string input - parse JSON first
	If (Value type:C1509($input)=Is text:K8:3)
		$parsed:=JSON Parse:C1218($input)
		If ($parsed=Null:C1517)
			return {type: "invalid"; value: Null:C1517; error: "Failed to parse JSON"}
		End if
	Else
		$parsed:=$input
	End if

	// Check if batch (collection)
	If (Value type:C1509($parsed)=Is collection:K8:32)
		var $batch : Collection:=$parsed
		var $results : Collection:=[]
		var $item : Object
		For each ($item; $batch)
			$results.push(This:C1470._parseOne($item))
		End for each
		return {type: "batch"; value: $results}
	End if

	// Single message
	return This:C1470._parseOne($parsed)

	// Internal: Parse a single JSON-RPC message object
Function _parseOne($obj : Object) : Object
	// Validate jsonrpc version
	If ($obj.jsonrpc#"2.0")
		return {type: "invalid"; value: Null:C1517; error: "Invalid or missing jsonrpc version"}
	End if

	// Determine message type based on properties
	var $hasId : Boolean:=OB Is defined:C1231($obj; "id")
	var $hasMethod : Boolean:=OB Is defined:C1231($obj; "method")
	var $hasResult : Boolean:=OB Is defined:C1231($obj; "result")
	var $hasError : Boolean:=OB Is defined:C1231($obj; "error")

	Case of
			// Error response: has id and error
		: ($hasId && $hasError)
			var $errorData : cs:C1710.ErrorData:=cs:C1710.ErrorData.new(\
				$obj.error.code; \
				$obj.error.message; \
				$obj.error.data)
			return {type: "error"; value: cs:C1710.Error.new($obj.id; $errorData)}

			// Success response: has id and result
		: ($hasId && $hasResult)
			return {type: "response"; value: cs:C1710.Response.new($obj.id; $obj.result)}

			// Request: has id and method
		: ($hasId && $hasMethod)
			var $request : cs:C1710.Request:=cs:C1710.Request.new($obj.method; $obj.params)
			$request.id:=$obj.id
			return {type: "request"; value: $request}

			// Notification: has method but no id
		: ($hasMethod && Not:C34($hasId))
			return {type: "notification"; value: cs:C1710.Notification.new($obj.method; $obj.params)}

		Else
			return {type: "invalid"; value: Null:C1517; error: "Cannot determine message type"}
	End case 
	
	// Parse specifically as a response (returns Null if not a valid response)
Function parseResponse($obj : Object) : cs:C1710.Response
	If ($obj.jsonrpc#"2.0")
		return Null:C1517
	End if 
	If (Not:C34(OB Is defined:C1231($obj; "result")))
		return Null:C1517
	End if 
	return cs:C1710.Response.new($obj.id; $obj.result)
	
	// Parse specifically as an error (returns Null if not a valid error)
Function parseError($obj : Object) : cs:C1710.Error
	If ($obj.jsonrpc#"2.0")
		return Null:C1517
	End if 
	If (Not:C34(OB Is defined:C1231($obj; "error")))
		return Null:C1517
	End if 
	var $errorData : cs:C1710.ErrorData:=cs:C1710.ErrorData.new(\
		$obj.error.code; \
		$obj.error.message; \
		$obj.error.data)
	return cs:C1710.Error.new($obj.id; $errorData)
	
	// ============================================================================
	// Type checking methods
	// ============================================================================
	
	// Check if a message is a request (expects response)
Function isRequest($obj : Object) : Boolean
	return OB Is defined:C1231($obj; "method") && OB Is defined:C1231($obj; "id")
	
	// Check if a message is a notification (no response expected)
Function isNotification($obj : Object) : Boolean
	return OB Is defined:C1231($obj; "method") && Not:C34(OB Is defined:C1231($obj; "id"))
	
	// Check if a message is a response (success)
Function isResponse($obj : Object) : Boolean
	return OB Is defined:C1231($obj; "result") && OB Is defined:C1231($obj; "id")
	
	// Check if a message is an error response
Function isError($obj : Object) : Boolean
	return OB Is defined:C1231($obj; "error") && OB Is defined:C1231($obj; "id")

	// Check if input is a batch (collection of messages)
Function isBatch($input : Variant) : Boolean
	return Value type:C1509($input)=Is collection:K8:32
	
	// ============================================================================
	// Error codes 
	// ============================================================================
	
	
	// Check if an error code is in the standard JSON-RPC error range
Function isStandardError($code : Integer) : Boolean
	return ($code>=-32699) && ($code<=-32600)
	
	// Get a human-readable description for standard error codes
Function getErrorDescription($code : Integer) : Text
	Case of 
		: ($code=This:C1470.PARSE_ERROR)
			return "Parse error: Invalid JSON was received"
		: ($code=This:C1470.INVALID_REQUEST)
			return "Invalid Request: The JSON sent is not a valid Request object"
		: ($code=This:C1470.METHOD_NOT_FOUND)
			return "Method not found"
		: ($code=This:C1470.INVALID_PARAMS)
			return "Invalid params"
		: ($code=This:C1470.INTERNAL_ERROR)
			return "Internal error"
		: ($code=This:C1470.CONNECTION_CLOSED)
			return "Connection closed"
		: ($code=This:C1470.REQUEST_TIMEOUT)
			return "Request timeout"
		: ($code=This:C1470.URL_ELICITATION_REQUIRED)
			return "URL elicitation required"
		Else 
			return "Unknown error (code: "+String:C10($code)+")"
	End case 
	
	