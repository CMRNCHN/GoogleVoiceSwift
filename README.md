# GoogleVoiceSwift

A comprehensive Swift wrapper for Google Voice with OAuth 2.0 authentication, call management, messaging, and contact management.

## Features

- **OAuth 2.0 Authentication** - Secure authentication with automatic token refresh
- **Call Management** - View call history, make calls, manage active calls
- **SMS/Messaging** - Send and receive text messages
- **Contact Management** - Store, retrieve, and search contacts
- **Real-time Polling** - Background polling for new calls and messages
- **Event Callbacks** - Handle incoming calls, new messages, and call endings
- **Thread-Safe** - Uses Swift actors for safe concurrent access
- **Credential Storage** - Automatic persistence with flexible storage interface
- **Comprehensive Logging** - Built-in logging for debugging
- **Error Handling** - Detailed error types and recovery strategies
- **Multi-Platform** - Support for iOS, macOS, watchOS, and tvOS

## Installation

### Swift Package Manager

Add GoogleVoiceSwift to your `Package.swift`:

```swift
.package(url: "https://github.com/yourusername/GoogleVoiceSwift.git", from: "1.0.0")
```

Or add it via Xcode: File → Add Packages → Enter the repository URL

## Quick Start

### 1. Authentication

```swift
let integration = GoogleVoiceIntegration()

// Get authorization code from user (via browser OAuth flow)
let authCode = "authorization_code_from_oauth_flow"

try await integration.initializeAuthentication(
    code: authCode,
    clientId: "YOUR_CLIENT_ID",
    clientSecret: "YOUR_CLIENT_SECRET"
)
```

### 2. Start Polling

```swift
integration.startBackgroundPolling()
```

### 3. Use the API

```swift
// Get recent calls
let recentCalls = try await integration.getRecentCallsInfo()
print(recentCalls)

// Send a message
try await integration.sendTextMessage(
    to: "+1-800-555-1234",
    text: "Hello!"
)

// Get contacts
let contacts = try await integration.getContactsList()
print(contacts)
```

## Components

### GoogleVoiceClient
Low-level API client handling direct Google Voice API calls with automatic authentication and token refresh.

```swift
let client = GoogleVoiceClient()
let calls = try await client.getCallHistory()
try await client.makeCall(to: "+1-800-555-1234")
```

### GoogleVoiceManager
High-level manager providing simplified interface with polling and event handling.

```swift
let manager = GoogleVoiceManager()

await manager.onIncomingCall = { call in
    print("Incoming call from \(call.name ?? call.phoneNumber)")
}

await manager.startPolling(interval: 30)
```

### GoogleVoiceIntegration
Helper class for common integration patterns.

```swift
let integration = GoogleVoiceIntegration()
try await integration.makePhoneCall(to: "+1-800-555-1234")
```

## Usage Examples

### Making a Call

```swift
try await integration.makePhoneCall(to: "+1-800-555-1234")
```

### Sending Messages

```swift
try await integration.sendTextMessage(
    to: "+1-800-555-1234",
    text: "Hello! How are you?"
)
```

### Retrieving Messages

```swift
let messages = try await integration.getMessagesFor(phoneNumber: "+1-800-555-1234")
for message in messages {
    print("\(message.name ?? message.phoneNumber): \(message.text)")
}
```

### Searching Contacts

```swift
let contacts = try await integration.searchContactsByName("John")
for contact in contacts {
    print("\(contact.name): \(contact.phoneNumbers)")
}
```

### Setting Up Event Handlers

```swift
let manager = GoogleVoiceManager()

await manager.onIncomingCall = { call in
    print("Incoming call from \(call.name ?? call.phoneNumber)")
}

await manager.onNewMessage = { message, phoneNumber in
    print("New message from \(phoneNumber): \(message.text)")
}

await manager.startPolling(interval: 30)
```

## Data Models

### GoogleVoiceCall
Represents a phone call with:
- `id`: Unique identifier
- `phoneNumber`: Phone number involved
- `name`: Contact name (optional)
- `timestamp`: When the call occurred
- `duration`: Call duration in seconds
- `type`: CallType (.incoming, .outgoing, .missed)
- `read`: Whether call has been read

### GoogleVoiceMessage
Represents an SMS message with:
- `id`: Unique identifier
- `phoneNumber`: Phone number of sender/recipient
- `name`: Contact name (optional)
- `text`: Message content
- `timestamp`: When message was sent
- `read`: Whether message has been read
- `type`: MessageType (.incoming, .outgoing, .draft)

### GoogleVoiceContact
Represents a contact with:
- `id`: Unique identifier
- `name`: Contact name
- `phoneNumbers`: List of phone numbers
- `email`: Email address (optional)
- `lastCommunication`: Timestamp of last contact
- `starred`: Whether contact is starred

### GoogleVoiceConversation
Represents a message conversation with:
- `id`: Unique identifier
- `phoneNumber`: Phone number involved
- `name`: Contact name (optional)
- `lastMessage`: Last message text
- `lastTimestamp`: When last message was sent
- `messageCount`: Total messages in conversation
- `unreadCount`: Number of unread messages

## Error Handling

```swift
do {
    try await integration.sendTextMessage(to: phoneNumber, text: message)
} catch let error as GoogleVoiceError {
    switch error {
    case .invalidPhoneNumber:
        print("Phone number format is invalid")
    case .tokenExpired:
        print("Need to re-authenticate")
    case .rateLimited:
        print("Rate limited - wait before retrying")
    case .networkError(let underlying):
        print("Network error: \(underlying)")
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

## Credential Storage

Credentials are automatically saved to:
- **macOS**: `~/Library/Application Support/GoogleVoiceSwift/credentials.json`
- **iOS**: Application Documents directory
- **Custom**: Implement the `CredentialsStore` protocol

### Custom Credential Storage

```swift
actor MyCustomStore: CredentialsStore {
    func save(_ credentials: GoogleVoiceCredentials) async throws {
        // Custom save logic
    }

    func load() async throws -> GoogleVoiceCredentials? {
        // Custom load logic
    }

    func delete() async throws {
        // Custom delete logic
    }
}

let customStore = MyCustomStore()
let client = GoogleVoiceClient(credentialsStore: customStore)
```

## Threading and Concurrency

All components use Swift's actor model for thread safety:

```swift
// Always use await when calling methods
let manager = GoogleVoiceManager()
let calls = try await manager.getRecentCalls()
```

## Testing

Run the test suite:

```bash
swift test
```

Tests cover:
- Data model creation and validation
- Credentials management
- Manager initialization
- Event polling setup
- Mock credential store

## Troubleshooting

### "Invalid credentials" error
- Verify the OAuth flow completed successfully
- Check that Client ID and Client Secret are correct
- Ensure credentials file has proper permissions

### "Rate Limited" error
- Implement exponential backoff
- Reduce polling frequency
- Contact Google Cloud support if limits are too restrictive

### "Token Expired" error
- The wrapper automatically handles token refresh
- If this error persists, re-authenticate

### "Network Error"
- Check internet connectivity
- Verify Google Voice API is not experiencing outages
- Check firewall/proxy settings

## Logging

Enable debug logging to see what's happening:

```swift
// Debug logs are printed to console in DEBUG builds
GoogleVoiceLogger.log("Custom message", subsystem: "MyApp")
GoogleVoiceLogger.debug("Debug message", subsystem: "MyApp")
GoogleVoiceLogger.error("Error message", subsystem: "MyApp")
```

## Rate Limiting

Handle rate limiting with exponential backoff:

```swift
func callWithRetry(_ operation: () async throws -> Void, maxAttempts: Int = 3) async throws {
    var lastError: Error?
    
    for attempt in 0..<maxAttempts {
        do {
            try await operation()
            return
        } catch let error as GoogleVoiceError {
            if case .rateLimited = error {
                if attempt < maxAttempts - 1 {
                    let delay = pow(2.0, Double(attempt))
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    lastError = error
                    continue
                }
            }
            throw error
        }
    }
    
    if let error = lastError {
        throw error
    }
}
```

## API Reference

### GoogleVoiceManager Methods

| Method | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `authenticate` | code, clientId, clientSecret | Void | Authenticate with OAuth |
| `startPolling` | interval (optional) | Void | Start listening for updates |
| `stopPolling` | none | Void | Stop listening for updates |
| `getRecentCalls` | limit (optional) | [GoogleVoiceCall] | Get call history |
| `initiateCall` | phoneNumber | Void | Make a phone call |
| `getConversations` | none | [GoogleVoiceConversation] | Get all conversations |
| `getMessages` | phoneNumber | [GoogleVoiceMessage] | Get messages for contact |
| `sendMessage` | phoneNumber, text | Void | Send a text message |
| `getAllContacts` | none | [GoogleVoiceContact] | Get all contacts |
| `searchContacts` | query | [GoogleVoiceContact] | Search contacts by name |

## Requirements

- Swift 5.9+
- iOS 14.0+, macOS 12.0+, watchOS 7.0+, tvOS 14.0+

## License

This project is available under the MIT license. See LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
