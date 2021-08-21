//
//  Array.swift
//  Test2048Source
//
//  Created by SathizMacMini on 21/08/21.
//
import Foundation

extension Array {
    var size: Int { return Int(sqrt(Double(count))) }
    
    subscript(x: Int, y: Int) -> Element {
        get { return self[(y * size) + x] }
        set { self[(y * size) + x] = newValue }
    }
    
    func coord(at index: Int) -> (x: Int, y: Int) {
        return (x: index % size, y: Int(index / size))
    }
    
    func randomElement() -> Element? {
        return self.count > 0 ? self[Int(arc4random_uniform(UInt32(self.count)))] : nil
    }
}

extension Array where Element : Equatable {
    func indecies(of value: Element) -> [(x: Int, y: Int)] {
        return self.enumerated().compactMap { $0.element == value ? coord(at: $0.offset) : nil }
    }
}
