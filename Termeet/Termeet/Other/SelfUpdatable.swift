//
//  SelfUpdatable.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 26.05.2025.
//

/**
Protocol enabling self-modification via closure.
Provides default implementation for mutable updates.
*/
protocol SelfUpdatable {
    mutating func update(_ changes: (inout Self) -> Void)
}

extension SelfUpdatable {
    mutating func update(_ changes: (inout Self) -> Void) {
        changes(&self)
    }
}
