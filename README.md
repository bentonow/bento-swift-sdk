

<p align="center"><img src="/art/bento-swift-sdk.png" alt="Logo Bento Swift SDK"></p>



> [!TIP]
> Need help? Join our [discord](https://discord.com/invite/ssXXFRmt5F) or email jesse@bentonow.com for personalized support.

The Bento Swift SDK makes it quick and easy to build an excellent analytics experience in your iOS application. We provide powerful and customizable APIs that can be used out-of-the-box to track your users' behavior and manage subscribers. We also expose low-level APIs so that you can build fully custom experiences.

Get started with our [📚 integration guides](https://docs.bentonow.com/) and [example projects](https://github.com/bentonow/bento_ios_example), or [📘 browse the SDK reference](https://docs.bentonow.com/subscribers).


❤️ Thank you [@ziptied](https://github.com/ziptied) for your contribution.


Table of contents
=================

<!--ts-->
   * [Features](#features)
   * [Requirements](#requirements)
   * [Getting started](#getting-started)
      * [Installation](#installation)
      * [Initialization](#initialization)
   * [Modules](#modules)
   * [Thread Safety](#thread-safety)
   * [Contributing](#contributing)
   * [License](#license)
<!--te-->

## Features

* **Simple event tracking**: We make it easy for you to track user events and behavior in your application.
* **Subscriber management**: Easily add, update, and remove subscribers from your Bento account.
* **Custom fields**: Track and update custom fields for your subscribers to store additional data.
* **Email validation**: Validate email addresses to ensure data quality.
* **Swift concurrency**: Built with modern Swift features for efficient asynchronous operations.

## Requirements

The Bento Swift SDK requires iOS 13.0+ and Swift 5.5+.

Bento Account for a valid SITE_UUID, PUBLISHABLE_KEY & SECRET_KEY.

## Getting started

### Installation

You can install the Bento Swift SDK using Swift Package Manager. Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/bentonow/bento-swift-sdk.git", from: "1.0.0")
]
```

### Initialization

Initialize the Bento client:

```swift
let bentoAPI = BentoAPI(siteUUID: "your-site-uuid", username: "your-username", password: "your-password")
```

## Modules

### Event Submission

Submit events to Bento.

```swift
let event = BentoEvent(type: "purchase", email: "user@example.com", fields: ["product": "T-shirt"], details: ["size": "M"], date: Date())
do {
    let response = try await bentoAPI.submitEvents([event])
    print("Submitted \(response.results) events")
} catch {
    print("Error submitting events: \(error)")
}
```

### Email Validation

Validate an email address.

```swift
do {
    let isValid = try await bentoAPI.validateEmail(email: "user@example.com", name: "John Doe", userAgent: "Mozilla/5.0", ip: "192.168.1.1")
    print("Is email valid? \(isValid)")
} catch {
    print("Error validating email: \(error)")
}
```

### Subscriber Management

Fetch subscriber information.

```swift
do {
    let response = try await bentoAPI.fetchSubscriber(email: "user@example.com")
    print("Subscriber UUID: \(response.data.attributes.uuid)")
    print("Subscriber Fields: \(response.data.attributes.fields)")
} catch {
    print("Error fetching subscriber: \(error)")
}
```

### Subscriber Commands

Execute various subscriber commands.

#### Add Tag

```swift
let command = SubscriberCommand.addTag(email: "user@example.com", tag: "VIP")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Tag added successfully")
} catch {
    print("Error adding tag: \(error)")
}
```

#### Remove Tag

```swift
let command = SubscriberCommand.removeTag(email: "user@example.com", tag: "VIP")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Tag removed successfully")
} catch {
    print("Error removing tag: \(error)")
}
```

#### Add Field

```swift
let command = SubscriberCommand.addField(email: "user@example.com", field: "favorite_color", value: "blue")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Field added successfully")
} catch {
    print("Error adding field: \(error)")
}
```

#### Remove Field

```swift
let command = SubscriberCommand.removeField(email: "user@example.com", field: "favorite_color")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Field removed successfully")
} catch {
    print("Error removing field: \(error)")
}
```

#### Subscribe

```swift
let command = SubscriberCommand.subscribe(email: "user@example.com")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("User subscribed successfully")
} catch {
    print("Error subscribing user: \(error)")
}
```

#### Unsubscribe

```swift
let command = SubscriberCommand.unsubscribe(email: "user@example.com")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("User unsubscribed successfully")
} catch {
    print("Error unsubscribing user: \(error)")
}
```

#### Change Email

```swift
let command = SubscriberCommand.changeEmail(oldEmail: "olduser@example.com", newEmail: "newuser@example.com")
do {
    let response = try await bentoAPI.executeCommand(command)
    print("Email changed successfully")
} catch {
    print("Error changing email: \(error)")
}
```

## Thread Safety

All API methods are designed to be called from any thread. The completion handlers are always called on the main thread, making it safe to update your UI directly from within the completion handler.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bentonow/bento-swift-sdk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](CODE_OF_CONDUCT.md) code of conduct.

## License

The Bento SDK for Swift is available as open source under the terms of the [MIT License](LICENSE.md).
