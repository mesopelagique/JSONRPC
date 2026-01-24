
property jsonrpc : Text:="2.0"
property id : Text
property method : Text
property params : Object  // XXX: or collection?

Class constructor($name : Text; $params : Object)
	This:C1470.id:=Generate UUID:C1066
	This:C1470.method:=$name
	This:C1470.params:=$params
	