import SwiftUI

private struct Constants {
    static let appName = "Termeet"
    static let registrationText = "Регистрация"
    static let loginText = "Вход"
    static let mailText = "Почта"
    static let passwordText = "Пароль"
    static let mailPlaceholderText = "Введите почту"
    static let passwordPlaceholderText = "Введите пароль"
    static let infoText = "Для регистрации потребуется подтверждение почты"
    static let haveAccountText = "Уже есть аккаунт?"
    static let noAccountText = "Еще нет аккаунта?"
    static let confirmButtonText = "Подтвердить почту"
    static let loginButtonText = "Войти"
    static let forgetPasswordText = "Забыли пароль?"
    static let choiseText = "или"
    static let yandexImageName = "y.circle.fill"
    static let googleImageName = "g.circle.fill"
    static let showPasswordImageName = "eye"
    static let hidePasswordImageName = "eye.slash"
    static let yandexContinueText = "Продолжить с помощью Яндекс"
    static let googleContinueText = "Продолжить с помощью Google"
    static let registerStackSpacing: CGFloat = 24
    static let bodyStackSpacing: CGFloat = 12
    static let buttonStackSpacing: CGFloat = 10
    static let buttonHeight: CGFloat = 43
    static let cornerRadius: CGFloat = 10
    static let borederWidth: CGFloat = 1
    static let bottomPadding: CGFloat = 20
}

//TODO: Move out logic to ViewModel
enum AuthorizationType {
    case registration
    case login
}

struct AuthorizationView: View {
    
    let viewType: AuthorizationType
    @State private var password: String = ""
    @State private var isShowingPassword: Bool = false
    
    var body: some View {
        VStack {
            VStack(spacing: Constants.registerStackSpacing) {

                Text(Constants.appName)
                    .font(.headline)

                Text( viewType == .registration
                      ? Constants.registrationText
                      : Constants.loginText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: Constants.buttonHeight, alignment: .leading)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: Constants.bodyStackSpacing) {
                    Text(Constants.mailText)
                        .font(.subheadline)
                        .foregroundColor(.black)
                    TextField(Constants.mailPlaceholderText, text: .constant(""))
                        .padding()
                        .frame(maxHeight: Constants.buttonHeight)
                        .overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(Color.gray, lineWidth: Constants.borederWidth))
      
                    if viewType == .registration {
                        Text(Constants.infoText)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else {
                        VStack(alignment: .leading, spacing: Constants.bodyStackSpacing) {
                            Text(Constants.passwordText)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            HStack {
                                if isShowingPassword {
                                    TextField(Constants.passwordPlaceholderText, text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField(Constants.passwordPlaceholderText, text: $password)
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
                            HStack {
                                Spacer()
                                Button {
                                    
                                } label : {
                                    Text(Constants.forgetPasswordText)
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: Constants.bodyStackSpacing) {

                Button {}
                label: {
                    Text(viewType == .registration
                         ? Constants.confirmButtonText
                         : Constants.loginButtonText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .frame(maxHeight: Constants.buttonHeight)
                        .background(Color.gray)
                        .cornerRadius(Constants.cornerRadius)
                }
                .padding(.horizontal)
                Button {}
                label: {
                    Text(viewType == .registration
                         ? Constants.haveAccountText
                         : Constants.noAccountText)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding()

                HStack {
                    VStack {
                        Divider()
                    }
                    Text(Constants.choiseText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    VStack {
                        Divider()
                    }
                }
                .padding(.horizontal)
                .padding()

                VStack(spacing: Constants.buttonStackSpacing) {
                    Button {}
                    label: {
                        HStack {
                            Image(systemName: Constants.yandexImageName)
                                .foregroundColor(.red)
                            Text(Constants.yandexContinueText)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .frame(height: Constants.buttonHeight)
                        .background(Color.black)
                        .cornerRadius(Constants.cornerRadius)
                    }
                    .padding(.horizontal)

                    Button {}
                    label: {
                        HStack {
                            Image(systemName: Constants.googleImageName)
                                .foregroundColor(.green)
                            Text(Constants.googleContinueText)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .frame(height: Constants.buttonHeight)
                        .background(Color.black)
                        .cornerRadius(Constants.cornerRadius)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, Constants.bottomPadding)
        }
        .frame(maxHeight: .infinity)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView(viewType: .login)
    }
}
