# JSONRPC

A JSON-RPC 2.0 protocol implementation for 4D.

## Overview

This library provides the core building blocks for working with the [JSON-RPC 2.0 specification](https://www.jsonrpc.org/specification) in 4D applications. It includes message types, factory methods, parsing utilities, and standard error codes.

## Classes

| Class | Description |
|-------|-------------|
| `Init` | Singleton with factory methods, parsing, and utilities |
| `Request` | JSON-RPC request message (expects response) |
| `Response` | JSON-RPC success response |
| `Error` | JSON-RPC error response |
| `ErrorData` | Error details container (code, message, data) |
| `Notification` | JSON-RPC notification (no response expected) |

## Usage

### Creating Messages

```4d
// Create a request (auto-generates UUID for id)
$request := cs.JSONRPC.Init.me.request("methodName"; {param1: "value"})

// Create a notification (no response expected)
$notification := cs.JSONRPC.Init.me.notification("eventName"; {data: "value"})

// Create a success response
$response := cs.JSONRPC.Init.me.response($requestId; {result: "data"})

// Create an error response
$error := cs.JSONRPC.Init.me.error($requestId; -32600; "Invalid Request"; Null)

// Create standalone error data
$errorData := cs.JSONRPC.Init.me.errorData(-32600; "Invalid Request"; Null)
```

### Parsing Messages

```4d
// Parse a JSON string into the appropriate message type
// Returns: {type: "request"|"response"|"error"|"notification"|"invalid"; value: Object}
$parsed := cs.JSONRPC.Init.me.parse($jsonString)

Case of
    : ($parsed.type = "request")
        // Handle request - $parsed.value is a Request object
    : ($parsed.type = "response")
        // Handle response - $parsed.value is a Response object
    : ($parsed.type = "error")
        // Handle error - $parsed.value is an Error object
    : ($parsed.type = "notification")
        // Handle notification - $parsed.value is a Notification object
    : ($parsed.type = "invalid")
        // Handle invalid message - $parsed.error contains description
End case

// Parse specifically as response or error (returns Null if wrong type)
$response := cs.JSONRPC.Init.me.parseResponse($obj)
$error := cs.JSONRPC.Init.me.parseError($obj)
```

### Batch Processing

JSON-RPC 2.0 supports batch requests (multiple messages in a single call). This library handles batches automatically:

```4d
// Parse a batch (array of JSON-RPC messages)
$batchJson := "[{\"jsonrpc\":\"2.0\",\"method\":\"notify\",\"params\":{}},{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"getData\"}]"
$parsed := cs.JSONRPC.Init.me.parse($batchJson)

If ($parsed.type = "batch")
    // $parsed.value is a collection of parsed messages
    For each ($message; $parsed.value)
        Case of
            : ($message.type = "request")
                // Handle request
            : ($message.type = "notification")
                // Handle notification
        End case
    End for each
End if

// Check if input is a batch
If (cs.JSONRPC.Init.me.isBatch($input))
    // Handle as batch
End if
```

### Type Checking

```4d
cs.JSONRPC.Init.me.isRequest($obj)       // Has id + method
cs.JSONRPC.Init.me.isResponse($obj)      // Has id + result
cs.JSONRPC.Init.me.isError($obj)         // Has id + error
cs.JSONRPC.Init.me.isNotification($obj)  // Has method, no id
cs.JSONRPC.Init.me.isBatch($input)       // Input is a collection
cs.JSONRPC.Init.me.isStandardError($code) // Code in -32699 to -32600 range
```

### Error Handling

```4d
// Get human-readable description for error codes
$description := cs.JSONRPC.Init.me.getErrorDescription(-32600)
// Returns: "Invalid Request: The JSON sent is not a valid Request object"
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| -32700 | `PARSE_ERROR` | Invalid JSON |
| -32600 | `INVALID_REQUEST` | Invalid request object |
| -32601 | `METHOD_NOT_FOUND` | Method does not exist |
| -32602 | `INVALID_PARAMS` | Invalid method parameters |
| -32603 | `INTERNAL_ERROR` | Internal JSON-RPC error |
| -32000 | `CONNECTION_CLOSED` | Connection was closed |
| -32001 | `REQUEST_TIMEOUT` | Request timed out |
| -32042 | `URL_ELICITATION_REQUIRED` | URL elicitation required |

Access error codes via the singleton:
```4d
cs.JSONRPC.Init.me.PARSE_ERROR        // -32700
cs.JSONRPC.Init.me.INVALID_REQUEST    // -32600
cs.JSONRPC.Init.me.METHOD_NOT_FOUND   // -32601
```

## License

MIT
