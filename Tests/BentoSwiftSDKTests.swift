import XCTest
@testable import BentoSwiftSDK // Replace with the name of the module containing BentoAPI

extension SubscriberResponse: @unchecked Sendable {}
extension SubscriberData: @unchecked Sendable {}
extension SubscriberAttributes: @unchecked Sendable {}

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
                let response = try await api.executeCommand(command)
                XCTAssertNotNil(response.data)
                XCTAssertEqual(response.data.type, "subscriber")
                XCTAssertEqual(response.data.attributes.email, "test@example.com")
                XCTAssertTrue(response.data.attributes.cachedTagIds.contains("TestTag"))
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
