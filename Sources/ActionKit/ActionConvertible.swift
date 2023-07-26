//
//  ActionConvertible.swift
//  ActionKit
//
//  Created by yukonblue on 07/26/2023.
//

public protocol ActionConvertible {

    associatedtype Value

    var toAnyAction: AnyAction<Value> { get }
}
