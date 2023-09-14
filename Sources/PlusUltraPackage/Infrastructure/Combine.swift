//
//  Combine.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 16/4/23.
//

import Combine

@propertyWrapper
public struct ValueSubject<T> {
    private var subject: CurrentValueSubject<T, Never>
    
    public var wrappedValue: T {
        get { subject.value }
        set { subject.send(newValue) }
    }
    
    public var projectedValue: CurrentValueSubject<T, Never> {
        subject
    }
    
    public init(wrappedValue: T) {
        self.subject = CurrentValueSubject(wrappedValue)
    }
}


public extension AnyPublisher {
     static func asyncToPublisher<T>(
        _ asyncCall: @escaping @Sendable () async throws -> T
    ) -> AnyPublisher<T, Error> {
        return Future<T, Error> { promise in
            Task {
                do {
                    let result = try await asyncCall()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
