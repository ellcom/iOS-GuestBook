//
//  ApiController.swift
//  GuestBook
//
//  Created by Elliot Adderton on 20/02/2019.
//  Copyright © 2019 Elliot Adderton. All rights reserved.
//

import Foundation

struct GuestBook: Codable {
    let code: Int
    let data: [GuestBookMessage]?
    let info: String?
    
    struct GuestBookMessage: Codable {
        let message: String
        let created: String
    }
}

class ApiController
{
    static func getMessages(callback:@escaping (GuestBook?, Error?)->Void)
    {
        let url = URL(string: "http://localhost:3000/messages")
        let task = URLSession.shared.dataTask(with: url!) { (data, urlResponse, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    callback(nil,error)
                }
                return;
            }
            
            if let data = data, let jsonData = try? JSONDecoder().decode(GuestBook.self, from: data) {
                    DispatchQueue.main.async {
                        callback(jsonData,nil)
                    }
                    return

            }
            
            DispatchQueue.main.async {
                callback(nil,nil)
            }
        }
        
        task.resume()
    }
    
    
    static func postMessage(message: String, callback:@escaping (GuestBook?, Error?)->Void)
    {
        var url = URLComponents(string: "http://localhost:3000/addMessage")!
        url.queryItems = [ URLQueryItem(name: "message", value: message)]
        
        let task = URLSession.shared.dataTask(with: url.url!) { (data, urlResponse, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    callback(nil,error)
                }
                return;
            }
            
            if let data = data {
                let jsonData = try? JSONDecoder().decode(GuestBook.self, from: data)
                
                DispatchQueue.main.async {
                    callback(jsonData,nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                callback(nil,nil)
            }
        }
        
        task.resume()
    }
}
