//
//  File.swift
//  
//
//  Created by Rubén García on 14/9/23.
//

import SwiftUI

public extension View {
    func alert<A: View, T>(_ titleKey: LocalizedStringKey, has: Binding<T?>, @ViewBuilder actions: (T) -> A) -> some View {
        let isPresented = Binding(get: {
            return has.wrappedValue != nil
        }, set: { newValue in
            if !newValue {
                has.wrappedValue = nil
            }
        })
        return alert(titleKey, isPresented: isPresented, actions: {
            if let value = has.wrappedValue{
                actions(value)
            }
        })
    }

    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func `if`<Content: View, ContentElse: View>(
        _ condition: Bool,
        transform: (Self) -> Content,
        else: ((Self) -> ContentElse)
    ) -> some View {
        if condition {
            transform(self)
        } else {
            `else`(self)
        }
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

public extension URL {
    func open() {
#if os(iOS)
        UIApplication.shared.open(self)
#elseif os(macOS)
        NSWorkspace.shared.open(self)
#endif
    }
}
