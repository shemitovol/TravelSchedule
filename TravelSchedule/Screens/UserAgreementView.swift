//
//  UserAgreementView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 05.09.2026.
//

import SwiftUI
import WebKit

struct UserAgreementView: View {
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    private let urlString = "https://yandex.ru/legal/practicum_offer"

    var body: some View {
        if let url = URL(string: urlString) {
            ZStack {
                WebView(url: url, isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)

                if isLoading {
                    ProgressView()
                        .tint(Color.ypBlackDay)
                }
            }
            .navigationTitle("Пользовательское соглашение")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                    Button {
                        dismiss()
                    } label: {
                        Image(.chevron)
                            .scaleEffect(x: -1, y: 1)
                            .foregroundStyle(Color.ypBlack)
                    }
                    .padding(.leading, -16)
            )
            .background(Color.ypWhite)
        }
    }
}

private struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {

    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let isLoading: Binding<Bool>

        init(isLoading: Binding<Bool>) {
            self.isLoading = isLoading
        }

        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation?
        ) {
            isLoading.wrappedValue = true
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation?
        ) {
            isLoading.wrappedValue = false
        }
    }
}


#Preview {
    UserAgreementView()
}
