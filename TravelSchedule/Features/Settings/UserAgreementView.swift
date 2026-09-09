//
//  UserAgreementView.swift
//  TravelSchedule
//
//  Created by Олег Сергеевич on 05.09.2026.
//

import SwiftUI
import WebKit

struct UserAgreementView: View {
    @State private var viewModel = UserAgreementViewModel()
    @State private var reloadID = UUID()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let url = viewModel.url {
            ZStack {
                if viewModel.state == .error {
                    errorView
                } else {
                    WebView(url: url, state: $viewModel.state)
                        .id(reloadID)
                        .ignoresSafeArea(edges: .bottom)

                    ProgressView()
                        .tint(Color.ypBlackDay)
                        .opacity(viewModel.state == .loading ? 1 : 0)
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

    private var errorView: some View {
        VStack(spacing: 16) {
            Text("Не удалось загрузить страницу")
                .font(.regular17)
                .foregroundStyle(Color.ypBlack)

            Button("Повторить") {
                viewModel.retry()
                reloadID = UUID()
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
    }
}

private struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var state: UserAgreementViewModel.State

    func makeCoordinator() -> Coordinator {
        Coordinator(state: $state)
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
        private let state: Binding<UserAgreementViewModel.State>

        init(state: Binding<UserAgreementViewModel.State>) {
            self.state = state
        }

        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation?
        ) {
            state.wrappedValue = .loading
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation?
        ) {
            state.wrappedValue = .loaded
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation?,
            withError: Error
        ) {
            state.wrappedValue = .error
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation?,
            withError: Error
        ) {
            state.wrappedValue = .error
        }
    }
}

