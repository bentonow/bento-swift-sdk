

<p align="center"><img src="/art/bento-swift-sdk.png" alt="Logo Bento Swift SDK"></p>

## Overview

The Bento Swift SDK provides a convenient way to interact with the Bento API in Swift applications. It covers all endpoints specified in the Bento API v1 documentation, including batch operations, fetch operations, commands execution, statistics retrieval, and experimental endpoints.

## Installation

### Swift Package Manager

BentoAPI can be installed through [Swift Package Manager](https://swift.org/package-manager/).

To add BentoAPI to your Xcode project, select File > Swift Packages > Add Package Dependency and enter the repository URL:

```
https://github.com/bentonow/bento-swift-sdk.git
```

Alternatively, you can add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/bentonow/bento-swift-sdk.git", from: "1.0.0")
]
```


## Initialization

To start using the Bento API, initialize the `BentoAPI` actor with your site UUID, username(BENTO_PUBLISHABLE_KEY), and password(BENTO_SECRET_KEY):

```swift
let bentoAPI = BentoAPI(siteUUID: "your-site-uuid", username: "your-username", password: "your-password")
```

## Submitting Events

You can submit events to Bento using the `submitEvents` function. Here's an example:

```swift
let event = BentoEvent(type: "purchase", email: "user@example.com", fields: ["product": "T-shirt"], details: ["size": "M"], date: Date())
do {
    let response = try await bentoAPI.submitEvents([event])
    print("Submitted \(response.results) events")
} catch {
    print("Error submitting events: \(error)")
}
```

This function allows you to batch submit multiple events at once.

## Validating Email

You can validate an email address using the `validateEmail` function:

```swift
do {
    let isValid = try await bentoAPI.validateEmail(email: "user@example.com", name: "John Doe", userAgent: "Mozilla/5.0", ip: "192.168.1.1")
    print("Is email valid? \(isValid)")
} catch {
    print("Error validating email: \(error)")
}
```

This function returns a boolean indicating whether the email is valid.

## Fetching Subscriber Information

To fetch subscriber information, use the `fetchSubscriber` function:

```swift
do {
    let response = try await bentoAPI.fetchSubscriber(email: "user@example.com")
    print("Subscriber UUID: \(response.data.attributes.uuid)")
    print("Subscriber Fields: \(response.data.attributes.fields)")
} catch {
    print("Error fetching subscriber: \(error)")
}
```

You can fetch a subscriber by email or UUID.

## Executing Subscriber Commands

The SDK supports various subscriber commands. Here are examples for each:

### Add Tag

```swift
let command = SubscriberCommand.addTag(email: "user@example.com", tag: "VIP")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Tag added successfully")
} catch {
    print("Error adding tag: \(error)")
}
```

### Remove Tag

```swift
let command = SubscriberCommand.removeTag(email: "user@example.com", tag: "VIP")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Tag removed successfully")
} catch {
    print("Error removing tag: \(error)")
}
```

### Add Field

```swift
let command = SubscriberCommand.addField(email: "user@example.com", field: "favorite_color", value: "blue")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Field added successfully")
} catch {
    print("Error adding field: \(error)")
}
```

### Remove Field

```swift
let command = SubscriberCommand.removeField(email: "user@example.com", field: "favorite_color")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Field removed successfully")
} catch {
    print("Error removing field: \(error)")
}
```

### Subscribe

```swift
let command = SubscriberCommand.subscribe(email: "user@example.com")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("User subscribed successfully")
} catch {
    print("Error subscribing user: \(error)")
}
```

### Unsubscribe

```swift
let command = SubscriberCommand.unsubscribe(email: "user@example.com")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("User unsubscribed successfully")
} catch {
    print("Error unsubscribing user: \(error)")
}
```

### Change Email

```swift
let command = SubscriberCommand.changeEmail(oldEmail: "olduser@example.com", newEmail: "newuser@example.com")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Email changed successfully")
} catch {
    print("Error changing email: \(error)")
}
```

These examples demonstrate how to use each command supported by the Bento API. 

Always handle potential errors when executing these commands.

## Thread Safety

All API methods are designed to be called from any thread. The completion handlers are always called on the main thread, making it safe to update your UI directly from within the completion handler.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bentonow/bento-swift-sdk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

## License

The package is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
