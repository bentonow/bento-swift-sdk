import XCTest
@testable import BentoSwiftSDK

extension SubscriberResponse: @unchecked @retroactive Sendable {}
extension SubscriberData: @unchecked @retroactive Sendable {}
extension SubscriberAttributes: @unchecked @retroactive Sendable {}

class BentoAPITests: XCTestCase {
    
    var api: BentoAPI!
    
    override func setUp() {
        super.setUp()
        // Use placeholder credentials for testing
        api = BentoAPI(siteUUID: "test-uuid", username: "testuser", password: "testpass")
    }
    
    func testBentoEventInitialization() {
        let event = BentoEvent(type: "test", email: "user@example.com")
        
        XCTAssertEqual(event.type, "test")
        XCTAssertEqual(event.email, "user@example.com")
        XCTAssertNil(event.fields)
        XCTAssertNil(event.details)
        XCTAssertNil(event.date)
    }
    
    func testBentoAPIInitialization() {
        XCTAssertNotNil(api)
    }
    
    func testSubmitEvents() async throws {
        let event = BentoEvent(type: "test", email: "user@example.com")
        
        do {
            let response = try await api.submitEvents([event])
            XCTAssertGreaterThanOrEqual(response.results, 0)
        } catch let error as URLError {
            // Print detailed information about the URLError
            print("URLError occurred:")
            print("Code: \(error.code.rawValue)")
            print("Description: \(error.localizedDescription)")
            
            if error.code.rawValue == -1011 {
                // This is likely the authentication error we're expecting
                print("Authentication failed as expected. Ensure valid credentials are used for actual API calls.")
            } else {
                XCTFail("Unexpected URLError: \(error.localizedDescription)")
            }
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
        
    }
    
    func testValidateEmail() async throws {
            do {
                let isValid = try await api.validateEmail(email: "test@example.com")
                XCTAssertTrue(isValid, "Email validation should return true for a valid email")
            } catch let error as URLError {
                if error.code.rawValue == -1011 {
                    print("Authentication failed as expected. Ensure valid credentials are used for actual API calls.")
                } else {
                    XCTFail("Unexpected URLError: \(error.localizedDescription)")
                }
            } catch {
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        }
        
        func testFetchSubscriber() async throws {
            do {
                let subscriber = try await api.fetchSubscriber(email: "test@example.com")
                XCTAssertNotNil(subscriber.data)
                XCTAssertEqual(subscriber.data.type, "subscriber")
                XCTAssertEqual(subscriber.data.attributes.email, "test@example.com")
            } catch let error as URLError {
                if error.code.rawValue == -1011 {
                    print("Authentication failed as expected. Ensure valid credentials are used for actual API calls.")
                } else {
                    XCTFail("Unexpected URLError: \(error.localizedDescription)")
                }
            } catch {
                XCTFail("Unexpected error: \(error.localizedDescription)")
            }
        }
        
    func testExecuteCommand() async throws {
        let command = SubscriberCommand.addTag(email: "test@example.com", tag: "TestTag")
        
        do {
            let result = try await api.executeCommand(command)
            XCTAssertGreaterThan(result, 0, "Expected a positive number of affected subscribers")
        } catch let error as URLError {
            if error.code.rawValue == -1011 {
                print("Authentication failed as expected. Ensure valid credentials are used for actual API calls.")
            } else {
                XCTFail("Unexpected URLError: \(error.localizedDescription)")
            }
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
}
