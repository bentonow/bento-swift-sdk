import Foundation

public struct BentoEvent: Codable, Sendable {
    public let type: String
    public let email: String
    public var fields: [String]?
    public var details: [String]?
    public var date: Date?
    
    public init(type: String, email: String, fields: [String]? = nil, details: [String]? = nil, date: Date? = nil) {
        self.type = type
        self.email = email
        self.fields = fields
        self.details = details
        self.date = date
    }
}

public struct BentoEventsResponse: Codable, Sendable {
    public let results: Int
}

public actor BentoAPI {
    private let baseURL = URL(string: "https://app.bentonow.com")!
    private let siteUUID: String
    private let username: String
    private let password: String
    private let session: URLSession
    
    public init(siteUUID: String, username: String, password: String) {
        self.siteUUID = siteUUID
        self.username = username
        self.password = password
        self.session = URLSession.shared
    }
    
    public func submitEvents(_ events: [BentoEvent]) async throws -> BentoEventsResponse {
        let url = baseURL.appendingPathComponent("/api/v1/batch/events")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "site_uuid", value: siteUUID)]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let credentials = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(["events": events])
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(BentoEventsResponse.self, from: data)
    }
    
    public func validateEmail(email: String, name: String? = nil, userAgent: String? = nil, ip: String? = nil) async throws -> Bool {
            var components = URLComponents(url: baseURL.appendingPathComponent("/api/v1/experimental/validation"), resolvingAgainstBaseURL: true)!
            components.queryItems = [
                URLQueryItem(name: "site_uuid", value: siteUUID),
                URLQueryItem(name: "email", value: email)
            ]
            
            if let name = name { components.queryItems?.append(URLQueryItem(name: "name", value: name)) }
            if let userAgent = userAgent { components.queryItems?.append(URLQueryItem(name: "user_agent", value: userAgent)) }
            if let ip = ip { components.queryItems?.append(URLQueryItem(name: "ip", value: ip)) }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let credentials = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode([String: Bool].self, from: data)
            return result["valid"] ?? false
        }
        
        public func fetchSubscriber(email: String? = nil, uuid: String? = nil) async throws -> SubscriberResponse {
            var components = URLComponents(url: baseURL.appendingPathComponent("/api/v1/fetch/subscribers"), resolvingAgainstBaseURL: true)!
            components.queryItems = [URLQueryItem(name: "site_uuid", value: siteUUID)]
            
            if let email = email { components.queryItems?.append(URLQueryItem(name: "email", value: email)) }
            if let uuid = uuid { components.queryItems?.append(URLQueryItem(name: "uuid", value: uuid)) }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let credentials = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(SubscriberResponse.self, from: data)
        }
    
    public func executeCommand(_ command: SubscriberCommand) async throws -> Int {
        let url = baseURL.appendingPathComponent("/api/v1/fetch/commands")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "site_uuid", value: siteUUID)]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let credentials = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(["command": [command]])
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let responseDict = try decoder.decode([String: Int].self, from: data)
        
        guard let result = responseDict["results"] else {
            throw URLError(.cannotParseResponse)
        }
        
        return result
    }
        
    
    }

public struct SubscriberResponse: Codable {
    public let data: SubscriberData
}

public struct SubscriberData: Codable {
    public let id: String
    public let type: String
    public let attributes: SubscriberAttributes
}

public struct SubscriberAttributes: Codable {
    public let uuid: String
    public let email: String
    public let fields: [String: String]
    public let cachedTagIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case uuid, email, fields
        case cachedTagIds = "cached_tag_ids"
    }
}

public enum SubscriberCommand: Codable {
    case addTag(email: String, tag: String)
    case removeTag(email: String, tag: String)
    case addField(email: String, field: String, value: String)
    case removeField(email: String, field: String)
    case subscribe(email: String)
    case unsubscribe(email: String)
    case changeEmail(oldEmail: String, newEmail: String)
    
    private enum CodingKeys: String, CodingKey {
        case command, email, query
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .addTag(let email, let tag):
            try container.encode("add_tag", forKey: .command)
            try container.encode(email, forKey: .email)
            try container.encode(tag, forKey: .query)
        case .removeTag(let email, let tag):
            try container.encode("remove_tag", forKey: .command)
            try container.encode(email, forKey: .email)
            try container.encode(tag, forKey: .query)
        case .addField(let email, let field, let value):
            try container.encode("add_field", forKey: .command)
            try container.encode(email, forKey: .email)
            try container.encode("\(field):\(value)", forKey: .query)
        case .removeField(let email, let field):
            try container.encode("remove_field", forKey: .command)
            try container.encode(email, forKey: .email)
            try container.encode(field, forKey: .query)
        case .subscribe(let email):
            try container.encode("subscribe", forKey: .command)
            try container.encode(email, forKey: .email)
        case .unsubscribe(let email):
            try container.encode("unsubscribe", forKey: .command)
            try container.encode(email, forKey: .email)
        case .changeEmail(let oldEmail, let newEmail):
            try container.encode("change_email", forKey: .command)
            try container.encode(oldEmail, forKey: .email)
            try container.encode(newEmail, forKey: .query)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let command = try container.decode(String.self, forKey: .command)
        let email = try container.decode(String.self, forKey: .email)
        
        switch command {
        case "add_tag":
            let tag = try container.decode(String.self, forKey: .query)
            self = .addTag(email: email, tag: tag)
        case "remove_tag":
            let tag = try container.decode(String.self, forKey: .query)
            self = .removeTag(email: email, tag: tag)
        case "add_field":
            let fieldValue = try container.decode(String.self, forKey: .query)
            let components = fieldValue.split(separator: ":")
            guard components.count == 2 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid field:value format"))
            }
            self = .addField(email: email, field: String(components[0]), value: String(components[1]))
        case "remove_field":
            let field = try container.decode(String.self, forKey: .query)
            self = .removeField(email: email, field: field)
        case "subscribe":
            self = .subscribe(email: email)
        case "unsubscribe":
            self = .unsubscribe(email: email)
        case "change_email":
            let newEmail = try container.decode(String.self, forKey: .query)
            self = .changeEmail(oldEmail: email, newEmail: newEmail)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown command"))
        }
    }
}
