//
//  InvalidPath.swift
//
//
//  Created by Lukáš Schmelcer on 14/05/2024.
//

import TokamakVapor

/// Invalid path representation
struct InvalidPath: TokamakVapor.View {
    var body: some TokamakVapor.View {
        VStack {
            Text("Sorry, could not find this URL")
                .foregroundColor(.red)
            Text("Try again with different path...")
                .foregroundColor(.black)
        }
    }
}
