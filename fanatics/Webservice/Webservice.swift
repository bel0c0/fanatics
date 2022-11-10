//
//  Webservice.swift
//  fanatics
//
//  Created by Benjamin Law on 11/10/22.
//

import Foundation
import OSLog

struct Person: Codable {
    var id: Int
    var name: String
    var email: String
    var gender: String
    var status: String // inactive
}

extension Person: Comparable {
    static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.name < rhs.name
    }
}

struct UploadPersonData: Codable {
    var name: String
}

enum NetworkError: Error {
    case badURL
    case invalidData
    case decodingError
    case responseError
    case requestError
}

enum PersonError: Error {
    case doesNotFound
    case authenticationError
    case updateError
    case jsonInputError
}

class PersonAPI {
    
    let urlSession: URLSession
    let baseURLString: String
    let networkLog = OSLog(subsystem: "com.blbusiness.fantics", category: "NETWORK")
    
    init(urlSession: URLSession, baseURLString: String) {
        self.urlSession = urlSession
        self.baseURLString = baseURLString
    }
    
    func getAllUsers(atPage page:Int = 0, perPage perPageNum: Int = 0, completion: @escaping (Result<[Person], Error>) -> Void) {
                
        var components = URLComponents(string: baseURLString)
        guard let _ = components else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        // if either page or perPageNum is negative, we remove the filter and request all data
        if page > 0 && perPageNum > 0 {
            components?.queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(perPageNum))
            ]
        }
        
        guard let url = components?.url else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.responseError))
                return
            }
                        
            switch response.statusCode {
            case 200:
                let totalPage = response.value(forHTTPHeaderField: "X-Pagination-Pages") ?? "0"
                os_log("total page: %@ ", log: self.networkLog, type: .debug, totalPage)
                print()
                let persons = try? JSONDecoder().decode([Person].self, from: data)
                if let persons = persons {
                    completion(.success(persons))
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            case 404:
                completion(.failure(PersonError.doesNotFound))
            default: // we don't handle the rest of 200s header
                completion(.failure(NetworkError.responseError))
            }
        }.resume()
    }
    
    func modifyPerson(_ person:Person, name newName: String, completion: @escaping (Result<Person, Error>) -> Void) {
        
        guard let url = URL(string: baseURLString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        let urlWithId = url.appendingPathComponent(String(person.id))
        let uploadPersonData = UploadPersonData(name: newName)
        
        guard let jsonData = try? JSONEncoder().encode(uploadPersonData) else {
            completion(.failure(PersonError.jsonInputError))
            return
        }
        
        var request = URLRequest(url: urlWithId)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        urlSession.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: error calling PUT")
                completion(.failure(error!))
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.responseError))
                return
            }
            
            switch response.statusCode {
            case 200:
                let updatedPerson = try? JSONDecoder().decode(Person.self, from: data)
                if let updatedPerson = updatedPerson {
                    if updatedPerson.name == newName {
                        completion(.success(updatedPerson))
                    }
                    else {
                        completion(.failure(PersonError.updateError))
                    }
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            case 404:
                completion(.failure(PersonError.doesNotFound))
            default: // we don't handle the rest of 200s header
                completion(.failure(NetworkError.responseError))
            }
        }.resume()
    }
    
    func deleteUserById(_ id:Int, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let url = URL(string: baseURLString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        let urlWithId = url.appendingPathComponent(String(id))
        var request = URLRequest(url: urlWithId)
        request.httpMethod = "DELETE"

        urlSession.dataTask(with: request) { (_, response, error) in
            
            guard error == nil else {
                print("Error: error calling PUT")
                completion(.failure(error!))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.responseError))
                return
            }
            
            switch response.statusCode {
            case 204:
                completion(.success(()))
            case 404:
                completion(.failure(PersonError.doesNotFound))
            default: // we don't handle the rest of 200s header
                completion(.failure(NetworkError.responseError))
            }
        }.resume()
    }

    func getUserById(_ id:Int, completion: @escaping (Result<Person, Error>) -> Void) {
        
        guard let url = URL(string: baseURLString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        let urlWithId = url.appendingPathComponent(String(id))
        let request = URLRequest(url: urlWithId)
        
        urlSession.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.responseError))
                return
            }
            
            os_log("Response code for id %d is %d ", log: self.networkLog, type: .debug, id, response.statusCode)
            
            switch response.statusCode {
            case 200:
                let person = try? JSONDecoder().decode(Person.self, from: data)
                if let person = person {
                    completion(.success(person))
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            case 404:
                completion(.failure(PersonError.doesNotFound))
            default: // we don't handle the rest of 200s header
                completion(.failure(NetworkError.responseError))
            }
        }.resume()
    }
}
