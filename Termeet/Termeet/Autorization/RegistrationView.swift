//
//  RegistrationView.swift
//  Termeet
//
//  Created by Данил Толстиков on 23.05.2025.
//


import SwiftUI

private struct Constants {
    static let registerStackSpacing: CGFloat = 40
    static let bodyStackSpacing: CGFloat = 16
    static let buttonHeight: CGFloat = 43
    static let cornerRadius: CGFloat = 10
    static let borederWidth: CGFloat = 1
    static let bottomPadding: CGFloat = 20
    static let appName = "Termeet"
    static let titleText = "Регистрация"
    static let nameText = "Имя"
    static let namePlaceholder = "Введите имя"
    static let passwordPlaceholderTexts = ["Введите пароль", "Повторите пароль"]
    static let passwordTexts = ["Пароль", "Пароль повторно"]
    static let underPasswordTexts = ["Пароль должен содержать не менее 8 символов и состоять из цифр и латинских букв", ""]
    static let registerText = "Зарегистрироваться"
    static let showPasswordImageName = "eye"
    static let hidePasswordImageName = "eye.slash"
    static let haveAccountButtonText = "Уже есть аккаунт?"
}

struct RegistrationView: View {
    @State private var password: String = ""
    @State private var isShowingPassword: Bool = false
    
    var body: some View {
        VStack {
            VStack(spacing: Constants.registerStackSpacing) {
                
                Text(Constants.appName)
                    .font(.headline)
                
                Text(Constants.titleText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: Constants.bodyStackSpacing) {
                    Text(Constants.nameText)
                        .font(.subheadline)
                        .foregroundColor(.black)
                    TextField(Constants.namePlaceholder, text: .constant(""))
                        .padding()
                        .frame(maxHeight: Constants.buttonHeight)
                        .overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(Color.gray, lineWidth: Constants.borederWidth))
                }
                
                ForEach(0..<2, id: \.self) { view in
                    VStack(alignment: .leading, spacing: Constants.bodyStackSpacing) {
                        Text(Constants.passwordTexts[view])
                            .font(.subheadline)
                            .foregroundColor(.black)
                        HStack {
                            if isShowingPassword {
                                TextField(Constants.passwordPlaceholderTexts[view], text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField(Constants.passwordPlaceholderTexts[view], text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            Button {isShowingPassword.toggle()}
                            label: {
                                Image(systemName: isShowingPassword
                                      ? Constants.hidePasswordImageName
                                      : Constants.showPasswordImageName)
                                .foregroundStyle(.gray)
                            }
                        }
                        .padding()
                        .frame(maxHeight: Constants.buttonHeight)
                        .overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(Color.gray, lineWidth: Constants.borederWidth))
                        Text(Constants.underPasswordTexts[view])
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.gray)
                    }
                }

                
            }
        }
        .padding(.horizontal)
        Spacer()
        
        VStack(spacing: Constants.bodyStackSpacing) {
            Button {}
            label: {
                Text(Constants.registerText)
                    .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .frame(height: Constants.buttonHeight)
                .background(Color.black)
                .cornerRadius(Constants.cornerRadius)
            }
            .padding(.horizontal)
            
            Button {}
            label: {
                Text(Constants.haveAccountButtonText)
            }
        }
    }
}


#if DEBUG

#Preview {
    RegistrationView()
}

#endif
