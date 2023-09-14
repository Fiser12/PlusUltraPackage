//
//  SystemExtensions.swift
//  SyncTion
//
//  Created by rgarciah on 21/6/21.
//

import Foundation

public extension Date {
    static var zero: Date {
        Date(timeIntervalSince1970: 0)
    }
}

public extension String {
    func levDis(_ w2: String) -> Int {
        let w1 = self
        let empty = [Int](repeating: 0, count: w2.count)
        var last = [Int](0...w2.count)
        
        w1.enumerated().forEach { (i, char1) in
            var cur = [i + 1] + empty
            w2.enumerated().forEach { (j, char2) in
                cur[j + 1] = char1 == char2 ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        return last.last ?? 0
    }
}

public extension Sequence {
    func toDictionary<Key: Hashable>(with selectKey: (Iterator.Element) -> Key) -> [Key: Iterator.Element] {
        self.reduce(into: [:]) { partialResult, element in
            partialResult[selectKey(element)] = element
        }
    }
}

public extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
    
    subscript(optional key: Index) -> Element? {
        get {
            self[key]
        }
        
        set {
            guard self.indices.contains(key) else { return }
            guard let newValue else {
                self.remove(at: key)
                return
            }
            self[key] = newValue
        }
    }
    
    func next(of criteria: (Element) -> Bool, overflow: Bool = false) -> Element? {
        guard let currentIndex = self.firstIndex(where: criteria) else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        if self.indices.contains(nextIndex) {
            return self[nextIndex]
        } else {
            return overflow ? nil : self.first
        }
    }
    
    func previous(of criteria: (Element) -> Bool, overflow: Bool = false) -> Element? {
        guard let currentIndex = self.firstIndex(where: criteria) else {
            return nil
        }
        
        let previousIndex = currentIndex - 1
        if self.indices.contains(previousIndex) {
            return self[previousIndex]
        } else {
            return overflow ? nil : self.last
        }
    }
}

public extension Array where Element: Identifiable {
    subscript(key: Element.ID) -> Element? {
        get {
            first {
                $0.id == key
            }
        }
        set {
            let index = firstIndex {
                $0.id == key
            }
            
            if let index, let newValue {
                self[index] = newValue
            } else if let newValue {
                append(newValue)
            }
        }
    }
    
    var dictionary: [Element.ID: Element] {
        self.toDictionary(with: \.id)
    }
}

@propertyWrapper
public struct CodableIgnored<T>: Codable {
    public var wrappedValue: T?
    
    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
