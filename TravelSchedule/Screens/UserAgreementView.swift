//
//  UserAgreementView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 05.09.2026.
//

import SwiftUI
import WebKit

struct UserAgreementView: View {
    @State private var hasError = false
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    private let urlString = "https://yandex.ru/legal/practicum_offer"

    var body: some View {
        if let url = URL(string: urlString) {
            ZStack {
                if hasError {
                    VStack(spacing: 16) {
                        Text("Не удалось загрузить страницу")
                            .font(.regular17)
                            .foregroundStyle(Color.ypBlack)

                        Button("Повторить") {
                            hasError = false
                            isLoading = true
                        }
                        .font(.bold17)
                        .foregroundStyle(Color.ypWhiteDay)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.ypBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(16)
                } else {
                    WebView(url: url, isLoading: $isLoading, hasError: $hasError)
                        .ignoresSafeArea(edges: .bottom)

                    if isLoading {
                        ProgressView()
                            .tint(Color.ypBlackDay)
                    }
                }
            }
            .navigationTitle("Пользовательское соглашение")
            .toolbar(.hidden, for: .tabBar)
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
    @Binding var hasError: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, hasError: $hasError)
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
        private let hasError: Binding<Bool>

        init(isLoading: Binding<Bool>, hasError: Binding<Bool>) {
            self.isLoading = isLoading
            self.hasError = hasError
        }

        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation?
        ) {
            isLoading.wrappedValue = true
            hasError.wrappedValue = false
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation?
        ) {
            isLoading.wrappedValue = false
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation?,
            withError: Error
        ) {
            isLoading.wrappedValue = false
            hasError.wrappedValue = true
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation?,
            withError: Error
        ) {
            isLoading.wrappedValue = false
            hasError.wrappedValue = true
        }
    }
}


#Preview {
    UserAgreementView()
}
