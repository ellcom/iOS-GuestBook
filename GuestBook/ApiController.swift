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
    static let urlMessages = URL(string: "http://localhost:3000/messages")
    static let urlStringAddMessage = String("http://localhost:3000/addMessage")
    
    @available(iOS 15.0, *)
    static func asyncGetMessages() async -> GuestBook?
    {
        do {
            
            let (data, _) = try await URLSession.shared.data(from: self.urlMessages!)
            let guestbook = try JSONDecoder().decode(GuestBook.self, from: data)
            return guestbook
            
        } catch {
            return nil
        }

    }
    
    @available(iOS 15.0, *)
    static func asyncPostMessage(message: String) async -> GuestBook?
    {
        var url = URLComponents(string: self.urlStringAddMessage)!
        url.queryItems = [ URLQueryItem(name: "message", value: message)]
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url.url!)
            let jsonData = try JSONDecoder().decode(GuestBook.self, from: data)
            
            return jsonData
        }
        catch {
            return nil;
        }
    }
    
    static func getMessages(callback:@escaping (GuestBook?, Error?)->Void)
    {
        let task = URLSession.shared.dataTask(with: self.urlMessages!) { (data, urlResponse, error) in
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
        var url = URLComponents(string: self.urlStringAddMessage)!
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
