// A JSON-RPC notification which does not expect a response.

property jsonrpc : Text:="2.0"
property method : Text
property params : Object

Class constructor($method : Text; $params : Object)
	This.method:=$method
	This.params:=$params
	
