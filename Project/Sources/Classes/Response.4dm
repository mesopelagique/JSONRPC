// A successful (non-error) response to a request.

property jsonrpc : Text:="2.0"
property id : Variant  // Text or Integer
property result : Object

Class constructor($id : Variant; $result : Object)
	This.id:=$id
	This.result:=$result
		
