//
//  ActionObserver.swift
//  ActionKit
//
//  Created by yukonblue on 07/13/2022.
//

import SwiftUI
import Combine

@propertyWrapper
public class ActionObserver<Value> {

    // MARK: Public types

    public class Adapter {
        public let observer: ActionObserver<Value>

        public var action: AnyAction<Value> {
            get {
                observer.action
            }
            set {
                observer.action = newValue
            }
        }

        init(observer: ActionObserver<Value>) {
            self.observer = observer
            self.action = action
        }

        public var binding: Binding<Value> {
            self.observer.binding
        }
    }

    // MARK: - Private members

    private var action: AnyAction<Value> {
        didSet {
            self.wireUpActionSink()
        }
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public members

    public private(set) var value: Value

    public var binding: Binding<Value> {
        Binding<Value> {
            self.value
        } set: { valueToBeUpdatedTo in
            self.action.update(value: valueToBeUpdatedTo)
        }
    }

    // MARK: - Public initializers

    public init(initialValue: Value, action: AnyAction<Value>) {
        self.value = initialValue

        self.action = action
        self.wireUpActionSink()
    }

    public init(wrappedValue value: Value) {
        self.value = value
        self.action = NoopAction<Value>().toAnyAction
    }

    // MARK: - Property wrapper support

    public var wrappedValue: Value {
        get {
            value
        }
        set {
            self.action.update(value: newValue)
        }
    }

    public var projectedValue: Adapter {
        get {
            .init(observer: self)
        }
    }

    // MARK: - Private helpers

    private func wireUpActionSink() {
        self
            .action
            .publisher
            .sink { newValue in
                self.value = newValue
            }
            .store(in: &self.cancellables)
    }
}
