# GoogleVoiceSwift Setup Guide

## Prerequisites

- Swift 5.9 or later
- macOS 12.0+, iOS 14.0+, or other supported platforms
- Google Cloud account
- Google Voice account

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Create Project"
3. Enter a project name (e.g., "GoogleVoiceSwift")
4. Click "Create"

## Step 2: Enable the Google Voice API

1. In the Google Cloud Console, search for "Google Voice API"
2. Click on the API result
3. Click "Enable"
4. Wait for the API to be enabled

## Step 3: Create OAuth 2.0 Credentials

1. In the Google Cloud Console, go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth 2.0 Client IDs"
3. If prompted, click "Configure Consent Screen" first:
   - Select "External" user type
   - Fill in the required fields
   - Add required scopes (search for "Google Voice")
   - Add test users
4. Return to "Credentials" and create "OAuth 2.0 Client IDs"
5. Select "Desktop application" as the application type
6. Click "Create"
7. Copy your **Client ID** and **Client Secret**

## Step 4: Set Up Your Swift Project

### Option A: Using Swift Package Manager

```bash
git clone https://github.com/yourusername/GoogleVoiceSwift.git
cd GoogleVoiceSwift
swift build
```

### Option B: Adding to an Existing Project

In your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/GoogleVoiceSwift.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["GoogleVoiceSwift"]
    )
]
```

## Step 5: Implement OAuth Flow

Create an OAuth flow handler in your app to get the authorization code:

```swift
import Foundation

class GoogleVoiceOAuthFlow {
    let clientId: String
    let clientSecret: String
    let redirectURI = "http://localhost:8080/callback"
    
    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    func getAuthorizationURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "accounts.google.com"
        components.path = "/o/oauth2/v2/auth"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "https://www.googleapis.com/auth/voice https://www.googleapis.com/auth/contacts"),
            URLQueryItem(name: "access_type", value: "offline")
        ]
        return components.url
    }
}
```

## Step 6: Initialize GoogleVoiceSwift

```swift
import GoogleVoiceSwift

// Get authorization code from OAuth flow
let authCode = "YOUR_AUTHORIZATION_CODE"
let clientId = "YOUR_CLIENT_ID"
let clientSecret = "YOUR_CLIENT_SECRET"

let integration = GoogleVoiceIntegration()

do {
    try await integration.initializeAuthentication(
        code: authCode,
        clientId: clientId,
        clientSecret: clientSecret
    )
    
    // Start polling for updates
    integration.startBackgroundPolling()
    
    // Use the API
    let recentCalls = try await integration.getRecentCallsInfo()
    print(recentCalls)
} catch {
    print("Error: \(error.localizedDescription)")
}
```

## Step 7: Configure Environment Variables (Optional)

Create a `.env` file in your project root:

```
GOOGLE_VOICE_CLIENT_ID=your_client_id_here
GOOGLE_VOICE_CLIENT_SECRET=your_client_secret_here
```

Load in your code:

```swift
struct GoogleVoiceConfig {
    static let clientId = ProcessInfo.processInfo.environment["GOOGLE_VOICE_CLIENT_ID"] ?? ""
    static let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_VOICE_CLIENT_SECRET"] ?? ""
}
```

## Troubleshooting Setup

### Issue: "Invalid Client ID"
- Verify the Client ID is correct
- Ensure the API is enabled in Google Cloud Console
- Check that OAuth consent screen is configured

### Issue: "Redirect URI mismatch"
- Ensure the redirect URI in your OAuth flow matches the one registered in Google Cloud Console
- Add all redirect URIs you plan to use in the OAuth credentials settings

### Issue: "Unauthorized"
- Verify the authorization code is not expired (valid for ~10 minutes)
- Ensure you're using the correct Client Secret
- Check that the user account has Google Voice enabled

### Issue: "Rate Limited"
- Google Voice API has rate limits
- Implement exponential backoff for retries
- Consider spreading requests over time
- Contact Google Cloud support for quota increase

## Next Steps

1. Read the [README.md](README.md) for API usage examples
2. Check out the test suite in `Tests/` for more examples
3. Review error handling patterns in the code
4. Implement custom credential storage if needed

## Security Considerations

### Protect Your Credentials

- Never commit `.env` files or credentials to version control
- Use environment variables for sensitive data
- Store credentials securely (Keychain on macOS, Keystore on Android)
- Implement token refresh before expiration
- Rotate credentials regularly

### OAuth Best Practices

- Use PKCE (Proof Key for Code Exchange) for public clients
- Validate state parameter in OAuth callback
- Use secure redirect URIs (HTTPS in production)
- Request minimum required scopes
- Implement proper error handling for auth failures

## Support

For issues or questions:
1. Check the [troubleshooting section](README.md#troubleshooting)
2. Review [Google Voice API documentation](https://developers.google.com/workspace)
3. Open an issue on GitHub
4. Contact support

## Additional Resources

- [Google Voice API Documentation](https://developers.google.com/workspace)
- [OAuth 2.0 Guide](https://developers.google.com/identity/protocols/oauth2)
- [Swift Concurrency Documentation](https://developer.apple.com/documentation/swift/swift-concurrency)
- [URLSession Documentation](https://developer.apple.com/documentation/foundation/urlsession)
