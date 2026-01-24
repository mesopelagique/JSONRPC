// Error information for JSON-RPC error responses.

property code : Integer
// The error type that occurred.

property message : Text
// A short description of the error. The message SHOULD be limited to a concise single sentence.

property data : Variant
// Additional information about the error. The value of this member is defined by the
// sender (e.g. detailed error information, nested errors etc.).

Class constructor($code : Integer; $message : Text; $data : Variant)
	This.code:=$code
	This.message:=$message
	This.data:=$data
	
