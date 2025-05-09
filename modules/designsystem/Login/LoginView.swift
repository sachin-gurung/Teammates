//
//  LoginView.swift
//  Teammates
//
//  Created by Sachin Gurung on 2/1/25.
//

import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseCore
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

private enum FocusableField: Hashable {
    case email
    case password
}

struct LoginView: View {
    var type: String
    var code: String

    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @FocusState private var focus: FocusableField?

    private func handleEmailAuth() {
        Task {
            let success: Bool
            if viewModel.flow == .login {
                success = await viewModel.signInWithEmailPassword()
            } else {
                success = await viewModel.signUpWithEmailPassword()
            }
            if success {
                viewModel.reset() // clears email, password, confirmPassword fields
                dismiss()
            }
        }
    }

    var body: some View {
        VStack {
            Image("Login")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minHeight: 300, maxHeight: 400)
            
            Text(viewModel.flow == .login ? "Login" : "Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Image(systemName: "at")
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)

            HStack {
                Image(systemName: "lock")
                SecureField("Password", text: $viewModel.password)
                    .focused($focus, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        handleEmailAuth()
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)
            
            if viewModel.flow == .signUp {
                HStack {
                    Image(systemName: "lock.rotation")
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .submitLabel(.done)
                }
                .padding(.vertical, 6)
                .background(Divider(), alignment: .bottom)
                .padding(.bottom, 8)
            }

            if !viewModel.errorMessage.isEmpty {
                VStack {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }

            Button(action: handleEmailAuth) {
                if viewModel.authenticationState != .authenticating {
                    Text(viewModel.flow == .login ? "Login" : "Create Account")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!viewModel.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)

            HStack {
                VStack { Divider() }
                Text("or")
                VStack { Divider() }
            }
            
            if FirebaseApp.app() != nil {
                GoogleSignInButton{
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .cornerRadius(8)
            } else {
                ProgressView("Loading Google Sign-in...")
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            
//            GoogleSignInButton {
//                Task {
//                    await viewModel.signInWithGoogle()
//                }
//            }
//            .frame(maxWidth: .infinity, minHeight: 50)
//            .cornerRadius(8)

            SignInWithAppleButton(.signIn) { request in
                viewModel.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                viewModel.handleSignInWithAppleCompletion(result)
            }
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .cornerRadius(8)

            HStack {
                Text(viewModel.flow == .login ? "Don't have an account yet?" : "Already have an account?")
                Button(action: { viewModel.switchFlow()}) {
                    Text(viewModel.flow == .login ? "Sign up" : "Login")
                }
            }
            .padding([.top, .bottom], 50)
        }
        .listStyle(.plain)
        .padding()
        .analyticsScreen(name: "\(Self.self)")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthenticationViewModel()

        LoginView(type: "string", code: "string")
            .environmentObject(viewModel)

        LoginView(type: "string", code: "string")
            .preferredColorScheme(.dark)
            .environmentObject(viewModel)
    }
}
