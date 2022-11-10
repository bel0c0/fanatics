//
//  ViewController.swift
//  fanatics
//
//  Created by Benjamin Law on 11/10/22.
//

import UIKit
import OSLog

class ViewController: UIViewController {
    
    let accessToken = "12c2d7f667ae5a78ad7783a0a6dd70ea698c75a5d1d5e6eef42c6b4a050ca87b"
    let baseURLString = "https://gorest.co.in/public/v2/users"
    let uiLog = OSLog(subsystem: "com.blbusiness.fantics", category: "UI")
    var session: URLSession {
        get {
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            return URLSession(configuration: sessionConfiguration)
        }
    }
    
    @IBAction func run(_ sender: Any) {
        let personAPI = PersonAPI(urlSession: session, baseURLString: baseURLString)
        personAPI.getAllUsers(atPage: 3, perPage: 5) { result in
            switch result {
            case .success(let persons):
                let sortedPersons = persons.sorted()
                if let lastPerson = sortedPersons.last {
                    os_log("The name of last user: %@ ", log: self.uiLog, type: .debug, lastPerson.name)
                    personAPI.modifyPerson(lastPerson, name: "John Doe") { result in
                        switch result {
                        case .success(let person):
                            print("modify success")
                            personAPI.deleteUserById(person.id) { result in
                                switch result {
                                case .success():
                                    print ("delete success")
                                case .failure(let error):
                                    print(error)
                                    print ("delete fail")
                                }
                            }
                             
                        case .failure(let error):
                            print("modify fail")
                            print(error)
                        }
                    }
                }
                else {
                    print("Cannot find last person")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func search(_ sender: Any) {
        let personAPI = PersonAPI(urlSession: session, baseURLString: baseURLString)
        personAPI.getUserById(5555) { result in
            switch result {
            case .success(let person):
                print(person)
            case .failure(let error):
                print(error)
            }
        }
    }
}

