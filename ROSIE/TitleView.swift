//
//  TitleView.swift
//  ROSIE
//
//  Created by Kenny Chen on 2026-03-30.
//

import SwiftUI

struct TitleView: View {
    var body: some View {
        HStack(spacing: 0) {
            Image("Logo")
                .resizable()
                .scaledToFit()
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    ForEach(Array(["R", ".", "O", ".", "S", ".", "I", ".", "E"].enumerated()), id: \.offset) { idx, letter in
                        Text(letter)
                            .font(.system(size: 33))
                            .fontWeight(.bold)
                            .frame(width: letter == "." ? 8 : 25)
                    }
                }
                HStack(spacing: 2) {
                    Image(systemName: "gear")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.black)
                    Text("Control Panel")
                        .font(.headline)
                        .fontWeight(.medium)
                }
            }
        }
    }
}
