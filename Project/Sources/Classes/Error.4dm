// A response to a request that indicates an error occurred.

property jsonrpc : Text:="2.0"
property id : Variant  // Text or Integer
property error : cs:C1710.ErrorData

Class constructor($id : Variant; $error : cs:C1710.ErrorData)
	This:C1470.id:=$id
	This:C1470.error:=$error
	
	