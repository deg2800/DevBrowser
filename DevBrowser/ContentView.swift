//
//  ContentView.swift
//  DevBrowser
//
//  Created by Derrick Goodfriend on 10/24/24.
//

import SwiftUI

struct ContentView: View {
    @State var pageTitle: String = ""
    @State var httpProtocol: String = "http"
    @State var host: String = "localhost"
    @State var port: String = "8888"
    @State var uri: String = ""
    @State var currentURL: String = "http://localhost:8888"
    @State var url = URL(string: "http://localhost:8888")!
    @State var showAlert: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Picker("", selection: $httpProtocol) {
                    Text("http://")
                        .tag("http")
                    Text("https://")
                        .tag("https")
                }
                .frame(width: 85)
                let hostSize: CGFloat = CGFloat(host.count) * 8.5
                let defaultSize: CGFloat = 80
                TextField("Host", text: $host)
                    .monospaced()
                    .frame(minWidth: defaultSize, maxWidth: hostSize > defaultSize ? hostSize : defaultSize)
                    .onSubmit {
                        go()
                    }
                Text(":")
                TextField("Port", text: $port)
                    .monospaced()
                    .frame(width: 50)
                    .onSubmit {
                        go()
                    }
                Text("/")
                TextField("URI", text: $uri)
                    .monospaced()
                    .onSubmit {
                        go()
                    }
                Button("Go") {
                    go()
                }
                .alert("Host is required", isPresented: $showAlert) {
                    Button("Close") {
                        showAlert = false
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 2)
            WebView(url: $url, pageTitle: $pageTitle)
            VStack(alignment: .leading) {
                HStack {
                    Text("\(url)")
                    Spacer()
                }
            }
            .padding(.bottom, 5)
            .padding(.leading, 5)
        }
        .navigationTitle(pageTitle + " [DevBrowser]")
        .onChange(of: url) { _, newValue in
            let urlString = newValue.absoluteString
            let prefix = httpProtocol + "://\(host)\(port.isEmpty ? "" : ":\(port)")/"
            if urlString.hasPrefix(prefix) {
                uri = urlString.replacing(prefix, with: "")
            }
        }
    }
    
    func go() {
        guard !host.isEmpty else {
            showAlert = true
            return
        }
        currentURL = httpProtocol + "://\(host)\(port.isEmpty ? "" : ":\(port)")/\(uri)"
        url = URL(string: currentURL)!
    }
}

#Preview {
    ContentView()
}
