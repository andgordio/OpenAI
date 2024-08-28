//
//  JSONRequest.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 12/19/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class JSONRequest<ResultType> {
    
    let body: Codable?
    let url: URL
    let method: String
    
    init(body: Codable? = nil, url: URL, method: String = "POST") {
        self.body = body
        self.url = url
        self.method = method
    }
}

extension JSONRequest: URLRequestBuildable {
    
    func build(token: String, organizationIdentifier: String?, timeoutInterval: TimeInterval) throws -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let organizationIdentifier {
            request.setValue(organizationIdentifier, forHTTPHeaderField: "OpenAI-Organization")
        }
        request.httpMethod = method
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        if let body = request.httpBody, let jsonString = String(data: body, encoding: .utf8) {
                
                let pattern = #"\\\""#
                let regex = try! NSRegularExpression(pattern: pattern)
                let range = NSRange(location: 0, length: jsonString.utf16.count)
                let modifiedString = regex.stringByReplacingMatches(in: jsonString, options: [], range: range, withTemplate: "\"")
                
                let pattern2 = #""schema":"\{"#
                let regex2 = try NSRegularExpression(pattern: pattern2)
                let range2 = NSRange(location: 0, length: modifiedString.utf16.count)
                let modifiedString2 = regex2.stringByReplacingMatches(in: modifiedString, options: [], range: range2, withTemplate: "\"schema\":{")
                
                let pattern3 = #"\}\}\", \"type"#
                let regex3 = try NSRegularExpression(pattern: pattern3)
                let range3 = NSRange(location: 0, length: modifiedString2.utf16.count)
                let modifiedString3 = regex3.stringByReplacingMatches(in: modifiedString2, options: [], range: range3, withTemplate: "}},\"type")
            
                let pattern4 = #"\}\"\}\}"#
                let regex4 = try NSRegularExpression(pattern: pattern4)
                let range4 = NSRange(location: 0, length: modifiedString3.utf16.count)
                let modifiedString4 = regex4.stringByReplacingMatches(in: modifiedString3, options: [], range: range3, withTemplate: "}}}")
            
            print("updating")
            print(modifiedString4)
                
            
            request.httpBody = modifiedString4.data(using: .utf8)
        } else {
            print("updating failed")
        }
        return request
    }
}
