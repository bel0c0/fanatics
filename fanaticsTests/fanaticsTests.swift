//
//  fanaticsTests.swift
//  fanaticsTests
//
//  Created by Benjamin Law on 11/10/22.
//

import XCTest
@testable import fanatics

final class fanaticsTests: XCTestCase {

    var personAPI: PersonAPI?
    var expectation: XCTestExpectation!
    let baseURLString = "https://gorest.co.in/public/v2/users"

    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        
        personAPI = PersonAPI(urlSession: urlSession, baseURLString: baseURLString)
        expectation = expectation(description: "Expectation")
    }
    
    func testGetAllUsersSuccessfully() {
        
        let mockJsonString = """
                                [
                                    {
                                        "id": 4901,
                                        "name": "Akshaj Kocchar",
                                        "email": "kocchar_akshaj@rohan.biz",
                                        "gender": "male",
                                        "status": "active"
                                    },
                                    {
                                        "id": 4900,
                                        "name": "Aagney Verma",
                                        "email": "aagney_verma@lind.com",
                                        "gender": "male",
                                        "status": "inactive"
                                    },
                                    {
                                        "id": 4899,
                                        "name": "Rohana Naik",
                                        "email": "naik_rohana@monahan.biz",
                                        "gender": "male",
                                        "status": "active"
                                    }
                            ]
                     """

        let data = mockJsonString.data(using: .utf8)
        
        guard let apiURL = URL(string: self.baseURLString) else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: ["X-Pagination-Pages" : "1"])!
            return (response, data)
        }
        
        personAPI?.getAllUsers() { result in
            switch result {
            case .success(let persons):
                XCTAssertTrue(persons.count == 3, "Number of persons return must be 3")
                if persons.count > 3 { // prevent index out of bounds
                    XCTAssertEqual(persons[0].id, 4901, "Incorrect id")
                    XCTAssertEqual(persons[0].name, "kshaj Kocchar", "Incorrect name")
                    XCTAssertEqual(persons[0].email,"kocchar_akshaj@rohan.biz", "Incorrect email")
                    XCTAssertEqual(persons[0].gender, "male", "Incorrect gender")
                    XCTAssertEqual(persons[0].status, "active", "Incorrect status")
                    
                    XCTAssertEqual(persons[1].id, 4900, "Incorrect id")
                    XCTAssertEqual(persons[1].name, "Aagney Verma", "Incorrect name")
                    XCTAssertEqual(persons[1].email,"aagney_verma@lind.com", "Incorrect email")
                    XCTAssertEqual(persons[1].gender, "male", "Incorrect gender")
                    XCTAssertEqual(persons[1].status, "inactive", "Incorrect status")
                    
                    XCTAssertEqual(persons[2].id, 4899, "Incorrect id")
                    XCTAssertEqual(persons[2].name, "Rohana Naik", "Incorrect name")
                    XCTAssertEqual(persons[2].email,"naik_rohana@monahan.biz", "Incorrect email")
                    XCTAssertEqual(persons[2].gender, "male", "Incorrect gender")
                    XCTAssertEqual(persons[2].status, "active", "Incorrect status")
                }

            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetUsersAtPageBySize() {
        
        let mockJsonString = """
                                [
                                    {
                                        "id": 4901,
                                        "name": "Akshaj Kocchar",
                                        "email": "kocchar_akshaj@rohan.biz",
                                        "gender": "male",
                                        "status": "active"
                                    },
                                    {
                                        "id": 4900,
                                        "name": "Aagney Verma",
                                        "email": "aagney_verma@lind.com",
                                        "gender": "male",
                                        "status": "inactive"
                                    },
                                    {
                                        "id": 4899,
                                        "name": "Rohana Naik",
                                        "email": "naik_rohana@monahan.biz",
                                        "gender": "male",
                                        "status": "active"
                                    }
                            ]
                     """

        let data = mockJsonString.data(using: .utf8)
        
        guard let apiURL = URL(string: self.baseURLString + "?page=1&per_page=3") else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: ["X-Pagination-Pages" : "3"])!
            return (response, data)
        }
        
        personAPI?.getAllUsers(atPage: 1, perPage: 3) { result in
            switch result {
            case .success(let persons):
                XCTAssertTrue(persons.count == 3, "Number of persons return must be 3")
                if persons.count > 3 { // prevent index out of bounds
                    XCTAssertEqual(persons[0].id, 4901, "Incorrect id")
                    XCTAssertEqual(persons[0].name, "kshaj Kocchar", "Incorrect name")
                    XCTAssertEqual(persons[0].email,"kocchar_akshaj@rohan.biz", "Incorrect email")
                    XCTAssertEqual(persons[0].gender, "male", "Incorrect gender")
                    XCTAssertEqual(persons[0].status, "active", "Incorrect status")
                    
                    XCTAssertEqual(persons[1].id, 4900, "Incorrect id")
                    XCTAssertEqual(persons[1].name, "Aagney Verma", "Incorrect name")
                    XCTAssertEqual(persons[1].email,"aagney_verma@lind.com", "Incorrect email")
                    XCTAssertEqual(persons[1].gender, "male", "Incorrect gender")
                    XCTAssertEqual(persons[1].status, "inactive", "Incorrect status")
                    
                    XCTAssertEqual(persons[2].id, 4899, "Incorrect id")
                    XCTAssertEqual(persons[2].name, "Rohana Naik", "Incorrect name")
                    XCTAssertEqual(persons[2].email,"naik_rohana@monahan.biz", "Incorrect email")
                    XCTAssertEqual(persons[2].gender, "male", "Incorrect gender")
                    XCTAssertEqual(persons[2].status, "active", "Incorrect status")
                }

            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetNoUsers() {
        
        guard let apiURL = URL(string: self.baseURLString) else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 404, httpVersion: nil, headerFields: ["X-Pagination-Pages" : "0"])!
            return (response, nil)
        }
        
        personAPI?.getAllUsers() { result in
            switch result {
            case .success(_):
                XCTFail("This should never be success")
            case .failure(let error):
                if let checkError = error as? PersonError {
                    XCTAssertEqual(checkError, PersonError.doesNotFound, "Match 404 does not found error")
                }
                else {
                    XCTFail("Other error was not expected: \(error)")
                }
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testModifyUserSuccessfully() {
        
        let mockJsonString = """
                                    {
                                        "id": 4901,
                                        "name": "John Doe",
                                        "email": "kocchar_akshaj@rohan.biz",
                                        "gender": "male",
                                        "status": "active"
                                    }
                            
                            """

        let data = mockJsonString.data(using: .utf8)
        
        guard let apiURL = URL(string: self.baseURLString + "/4901") else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let person = Person(id: 4901, name: "Akshaj Kocchar", email: "kocchar_akshaj@rohan.biz", gender: "male", status: "active")
        personAPI?.modifyPerson(person, name: "John Doe") { result in
            switch result {
            case .success(let updatedPerson):
                XCTAssertEqual(updatedPerson.id, 4901, "Incorrect id")
                XCTAssertEqual(updatedPerson.name, "John Doe", "Incorrect name")
                XCTAssertEqual(updatedPerson.email,"kocchar_akshaj@rohan.biz", "Incorrect email")
                XCTAssertEqual(updatedPerson.gender, "male", "Incorrect gender")
                XCTAssertEqual(updatedPerson.status, "active", "Incorrect status")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testModifyNonExistedUser() {
        
        guard let apiURL = URL(string: self.baseURLString + "/4901") else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        let person = Person(id: 4901, name: "Akshaj Kocchar", email: "kocchar_akshaj@rohan.biz", gender: "male", status: "active")
        personAPI?.modifyPerson(person, name: "John Doe") { result in
            switch result {
            case .success(_):
                XCTFail("Succes was not expected")
                
            case .failure(let error):
                if let checkError = error as? PersonError {
                    XCTAssertEqual(checkError, PersonError.doesNotFound, "Match 404 does not found error")
                }
                else {
                    XCTFail("Other error was not expected: \(error)")
                }
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteUser() {
        
        guard let apiURL = URL(string: self.baseURLString + "/4901") else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 204, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        let person = Person(id: 4901, name: "Akshaj Kocchar", email: "kocchar_akshaj@rohan.biz", gender: "male", status: "active")
        personAPI?.deleteUserById(person.id) { result in
            switch result {
            case .success(_):
                print("Delete Success")
            case .failure(let error):
                if let checkError = error as? PersonError {
                    XCTAssertEqual(checkError, PersonError.doesNotFound, "Match 404 does not found error")
                }
                else {
                    XCTFail("Other error was not expected: \(error)")
                }
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteNonExistedUser() {
        
        guard let apiURL = URL(string: self.baseURLString + "/4901") else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        let person = Person(id: 4901, name: "Akshaj Kocchar", email: "kocchar_akshaj@rohan.biz", gender: "male", status: "active")
        personAPI?.deleteUserById(person.id) { result in
            switch result {
            case .success(_):
                XCTFail("Success was not expected")
            case .failure(let error):
                if let checkError = error as? PersonError {
                    XCTAssertEqual(checkError, PersonError.doesNotFound, "Match 404 does not found error")
                }
                else {
                    XCTFail("Other error was not expected: \(error)")
                }
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetUserByIdSuccessfully() {
        
        let mockJsonString = """
                                    {
                                        "id": 4901,
                                        "name": "Akshaj Kocchar",
                                        "email": "kocchar_akshaj@rohan.biz",
                                        "gender": "male",
                                        "status": "active"
                                    }
                            
                            """

        let data = mockJsonString.data(using: .utf8)
        
        guard let apiURL = URL(string: self.baseURLString + "/4901") else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let person = Person(id: 4901, name: "Akshaj Kocchar", email: "kocchar_akshaj@rohan.biz", gender: "male", status: "active")
        personAPI?.getUserById(person.id) { result in
            switch result {
            case .success(let person):
                XCTAssertEqual(person.id, 4901, "Incorrect id")
                XCTAssertEqual(person.name, "Akshaj Kocchar", "Incorrect name")
                XCTAssertEqual(person.email,"kocchar_akshaj@rohan.biz", "Incorrect email")
                XCTAssertEqual(person.gender, "male", "Incorrect gender")
                XCTAssertEqual(person.status, "active", "Incorrect status")
                
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetNUserByIdWithNoReturn() {
        
        guard let apiURL = URL(string: self.baseURLString + "/4901") else {
            assertionFailure("Bad URL")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == apiURL else {
                throw NetworkError.requestError
            }
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        let person = Person(id: 4901, name: "Akshaj Kocchar", email: "kocchar_akshaj@rohan.biz", gender: "male", status: "active")
        personAPI?.getUserById(person.id) { result in
            switch result {
            case .success(_):
                XCTFail("Success was not expected")
            case .failure(let error):
                if let checkError = error as? PersonError {
                    XCTAssertEqual(checkError, PersonError.doesNotFound, "Match 404 does not found error")
                }
                else {
                    XCTFail("Other error was not expected: \(error)")
                }
            }
            self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
