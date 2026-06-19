import SwiftUI

struct MailInfoView: View {
    var body: some View {
        VStack(spacing: 24) {

            Text("Termeet")
                .font(.headline)

            Text("Регистрация")
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
 
            Text("На вашу почту было отправлено письмо для подтверждения. Пожалуйста, проверьте папку спам")
                .padding(.horizontal)
                .font(.custom("Arial", size: 17))

            Spacer()
            
            Text("Вы можете запросить повторно через 3:00")
                .fontWeight(.light)
                .foregroundStyle(.gray)
            Button {}
            label: {
                Text("Отправить повторно")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .frame(maxHeight: 43)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}

#if DEBUG

#Preview {
    MailInfoView()
}

#endif
