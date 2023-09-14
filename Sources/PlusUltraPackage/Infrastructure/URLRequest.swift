//
//  URLRequest.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 24/4/23.
//

import Foundation

public extension URLSession {
    func apiDataRequest(for request: URLRequest) async throws -> Data {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await self.data(for: request)
        } catch let nsError as NSError where nsError.code == NSURLErrorCancelled {
            throw APIError.canceled
        } catch {
            throw APIError.general(CodableError(error))
        }
        
        guard let response = response as? HTTPURLResponse, (200..<299).contains(response.statusCode) else {
            throw APIError(response, data: data)
        }
        return data
    }
    
    func request<T: Decodable>(_ request: URLRequest, _ _: T.Type) async throws -> T {
        let decoder = JSONDecoder()
        let data = try await apiDataRequest(for: request)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            log("Repository: Decoding failure, data: \(data) \(T.self)", level: .ERROR)
            log("Repository: Data to UTF8: \(String(data: data, encoding: String.Encoding.utf8) ?? "")", level: .DEBUG)
            throw APIError.json(data, CodableError(error))
        }
    }
}

public enum HTTPMethod {
    case get
    case post(Encodable?)
    case put(Encodable?)
    case delete
    case head
    case patch(Encodable?)
    case options
    case trace
    case connect
    
    var strMethod: String {
        switch self {
        case .get: return "GET"
        case .post(_): return "POST"
        case .put(_): return "PUT"
        case .delete: return "DELETE"
        case .head: return "HEAD"
        case .patch(_): return "PATCH"
        case .options: return "OPTIONS"
        case .trace: return "TRACE"
        case .connect: return "CONNECT"
        }
    }
    
    func apply(to request: URLRequest) -> URLRequest {
        var urlRequest = request
        urlRequest.httpMethod = strMethod

        switch self {
        case .post(let body), .put(let body), .patch(let body):
            guard let body else { return urlRequest }
            urlRequest.httpBody = try? JSONEncoder().encode(body)
        default: break
        }
        return urlRequest
    }
}


public extension URLRequest {
    func url(_ url: URL) -> URLRequest {
        var copy = self
        copy.url = url
        return copy
    }
    
    func method(_ method: HTTPMethod) -> URLRequest {
        method.apply(to: self)
    }
    
    func header(_ header: HTTPHeader, value: String) -> URLRequest {
        var copy = self
        copy.setValue(value, forHTTPHeaderField: header.rawValue)
        return copy
    }

    func header(_ header: String, value: String) -> URLRequest {
        var copy = self
        copy.setValue(value, forHTTPHeaderField: header)
        return copy
    }
    
}

public enum HTTPHeader: String {
    case accept = "Accept"
    case acceptCharset = "Accept-Charset"
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
    case authorization = "Authorization"
    case cacheControl = "Cache-Control"
    case connection = "Connection"
    case contentLength = "Content-Length"
    case contentMD5 = "Content-MD5"
    case contentType = "Content-Type"
    case cookie = "Cookie"
    case date = "Date"
    case expect = "Expect"
    case forwarded = "Forwarded"
    case from = "From"
    case host = "Host"
    case userAgent = "User-Agent"
    case upgrade = "Upgrade"
    case via = "Via"
    case warning = "Warning"
}


public enum APIError: Error, Codable {
    case canceled
    case json(Data, CodableError)
    case general(CodableError)
    case status(Int, Data?)
    case unknown
    case noHTTPURLResponse(Data?)
    
    public init(_ urlResponse: URLResponse, data: Data? = nil) {
        if let response = urlResponse as? HTTPURLResponse {
            self = .status(response.statusCode, data)
        } else {
            self = .noHTTPURLResponse(data)
        }
    }
}

public struct CodableError: Error, Codable {
    public let localizedDescription: String
    @CodableIgnored public var error: Error?
    
    public init(_ error: Error) {
        self.localizedDescription = error.localizedDescription
        self.error = error
    }
}
