//
//  MultipartFormDataRequest.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 02/04/2023.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class MultipartFormDataRequest<ResultType> {
    
    let body: MultipartFormDataBodyEncodable
    let url: URL
    let method: String
        
    init(body: MultipartFormDataBodyEncodable, url: URL, method: String = "POST") {
        self.body = body
        self.url = url
        self.method = method
    }
}

extension MultipartFormDataRequest: URLRequestBuildable {
    
    func build(token: String, organizationIdentifier: String?, timeoutInterval: TimeInterval) throws -> URLRequest {
        var request = URLRequest(url: url)
        let boundary: String = UUID().uuidString
        request.timeoutInterval = timeoutInterval
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let organizationIdentifier {
            request.setValue(organizationIdentifier, forHTTPHeaderField: "OpenAI-Organization")
        }
        print("building")
        request.httpBody = body.encode(boundary: boundary)
        print("building2" )
        
        if let body = request.httpBody, let jsonString = String(data: body, encoding: .utf8) {
            
            
                
                let pattern = #"\\\""#
                let regex = try! NSRegularExpression(pattern: pattern)
                let range = NSRange(location: 0, length: jsonString.utf16.count)
                let modifiedString = regex.stringByReplacingMatches(in: jsonString, options: [], range: range, withTemplate: "\"")
                
                let pattern2 = #""schema":"\{"#
                let regex2 = try NSRegularExpression(pattern: pattern2)
                let range2 = NSRange(location: 0, length: modifiedString.utf16.count)
                let modifiedString2 = regex2.stringByReplacingMatches(in: modifiedString, options: [], range: range2, withTemplate: "\"schema\":{")
                
//                let pattern3 = #"\}\}","\type\":\"json_schema\"}"#
//                let regex3 = try NSRegularExpression(pattern: pattern3)
//                let range3 = NSRange(location: 0, length: modifiedString2.utf16.count)
//                let modifiedString3 = regex3.stringByReplacingMatches(in: modifiedString2, options: [], range: range3, withTemplate: "}},\"type\":\"json_schema\"}")
            
            print("updating")
            print(modifiedString2)
                
            
            request.httpBody = modifiedString2.data(using: .utf8)
        } else {
            print("updating failed")
        }
        
        
        return request
    }
}
