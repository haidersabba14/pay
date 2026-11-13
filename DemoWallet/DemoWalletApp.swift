import SwiftUI

@main
struct DemoWalletApp: App {
    var body: some Scene {
        WindowGroup {
            WalletView()
                .environment(\.layoutDirection, .rightToLeft)
                .preferredColorScheme(.dark)
        }
    }
}

struct WalletView: View {
    @AppStorage("demoBalanceFils") private var balanceFils = 1_000_000
    @AppStorage("demoCardSuffix") private var cardSuffix = "1234"
    @State private var editing = false
    @State private var showInfo = false
    private let accent = Color(red: 0.35, green: 0.88, blue: 0.75)

    private var amount: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_BH")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: Double(balanceFils) / 1000)) ?? "0.000"
    }

    var body: some View {
        VStack(spacing: 0) {
            Label("للمزح فقط — غير صالح للدفع", systemImage: "exclamationmark.shield.fill")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(13)
                .background(accent)
                .foregroundStyle(.black)
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("أهلًا بك 👋").foregroundStyle(.secondary)
                            Text("محفظة تجريبية").font(.title.bold())
                        }
                        Spacer()
                        Image(systemName: "wallet.bifold.fill")
                            .font(.title).foregroundStyle(accent)
                            .padding(16).background(.white.opacity(0.07), in: Circle())
                    }
                    VStack(spacing: 16) {
                        Text("الرصيد الوهمي").foregroundStyle(.secondary)
                        Text(amount)
                            .font(.system(size: 43, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.45).lineLimit(1)
                            .environment(\.layoutDirection, .leftToRight)
                        Text("دينار بحريني · BHD").foregroundStyle(accent)
                        Text("للمزح فقط · هذا الرصيد ليس مالًا حقيقيًا")
                            .font(.footnote.bold()).foregroundStyle(accent)
                        Button { editing = true } label: {
                            Label("تعديل الرصيد والبطاقة", systemImage: "slider.horizontal.3")
                                .font(.headline).frame(maxWidth: .infinity).padding()
                        }
                        .background(accent, in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.black)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 28))

                    HStack(spacing: 12) {
                        demoAction("الدفع", icon: "qrcode")
                        demoAction("التحويل", icon: "arrow.left.arrow.right")
                        demoAction("الطلبات", icon: "doc.text")
                    }

                    Text("بطاقتك التجريبية").font(.title2.bold())
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text("DEMO CARD").font(.headline)
                            Spacer()
                            Image(systemName: "simcard").font(.title)
                        }
                        Text("DEMO •••• •••• \(cardSuffix)")
                            .font(.system(size: 22, weight: .medium, design: .monospaced))
                            .minimumScaleFactor(0.6).lineLimit(1)
                            .environment(\.layoutDirection, .leftToRight)
                        HStack {
                            Text("للمزح فقط — لا تعمل للدفع").font(.footnote.bold())
                            Spacer()
                            Text("BHD").bold()
                        }
                    }
                    .padding(24)
                    .foregroundStyle(.black)
                    .background(LinearGradient(colors: [accent, Color(red: 0.64, green: 0.84, blue: 1)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24))

                    VStack(alignment: .leading, spacing: 10) {
                        Label("نموذج محلي فقط", systemImage: "iphone")
                            .font(.headline)
                        Text("لا يوجد حساب بنكي أو دفع أو تحويل. جميع الأرقام وهمية ومحفوظة على جهازك فقط. هذا النموذج مستقل وغير تابع لـ BenefitPay أو أي بنك.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
                }
                .padding(22)
            }
        }
        .background(Color(red: 0.035, green: 0.055, blue: 0.08))
        .sheet(isPresented: $editing) {
            EditorView(balanceFils: $balanceFils, cardSuffix: $cardSuffix)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .alert("ميزة غير مفعلة", isPresented: $showInfo) {
            Button("حسنًا", role: .cancel) { }
        } message: {
            Text("هذا نموذج للمزح فقط. لا ينفذ أي دفع أو تحويل ولا ينشئ إيصالات.")
        }
    }

    private func demoAction(_ title: String, icon: String) -> some View {
        Button { showInfo = true } label: {
            VStack(spacing: 10) {
                Image(systemName: icon).font(.title2).foregroundStyle(accent)
                Text(title).font(.subheadline.bold())
                Text("تجريبي").font(.caption2).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 18)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

struct EditorView: View {
    @Binding var balanceFils: Int
    @Binding var cardSuffix: String
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var suffix = ""
    @State private var error = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("للمزح فقط — الأرقام وهمية وغير صالحة للدفع")
                        .font(.headline).foregroundStyle(.mint)
                }
                Section("الرصيد الوهمي بالدينار البحريني") {
                    TextField("مثل 1250.500", text: $amount)
                        .keyboardType(.decimalPad)
                        .environment(\.layoutDirection, .leftToRight)
                    Button("زيادة 100 دينار وهمي") {
                        guard let fils = parseFils(amount), fils <= 999_999_899_999 else {
                            error = "أدخل مبلغًا صالحًا قبل الزيادة."
                            return
                        }
                        amount = NSDecimalNumber(value: fils + 100_000).dividing(by: 1000).stringValue
                        error = ""
                    }
                }
                Section("آخر أربعة أرقام للبطاقة الوهمية") {
                    TextField("1234", text: $suffix).keyboardType(.numberPad)
                    Text("البادئة DEMO ثابتة. لا تدخل رقم بطاقة حقيقية.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                if !error.isEmpty { Text(error).foregroundStyle(.red) }
                Button("حفظ التعديلات") { save() }
                Button("إعادة القيم الافتراضية") {
                    amount = "1000.000"
                    suffix = "1234"
                    error = ""
                }
            }
            .navigationTitle("تعديل النموذج")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { dismiss() } } }
            .onAppear {
                amount = NSDecimalNumber(value: balanceFils).dividing(by: 1000).stringValue
                suffix = cardSuffix
            }
        }
    }

    private func normalized(_ input: String) -> String {
        input.map { ch in
            if let digit = ch.wholeNumberValue { return String(digit) }
            return ch == "٫" || ch == "," ? "." : String(ch)
        }.joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseFils(_ input: String) -> Int? {
        let value = normalized(input)
        guard value.range(of: #"^[0-9]{1,9}(\.[0-9]{1,3})?$"#, options: .regularExpression) != nil,
              let decimal = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) else { return nil }
        let fils = NSDecimalNumber(decimal: decimal * 1000).intValue
        return (0...999_999_999_999).contains(fils) ? fils : nil
    }

    private func save() {
        guard let fils = parseFils(amount) else {
            error = "أدخل مبلغًا من 0 إلى 999999999.999، بثلاث خانات عشرية كحد أقصى."
            return
        }
        let digits = normalized(suffix)
        guard digits.range(of: #"^[0-9]{4}$"#, options: .regularExpression) != nil else {
            error = "أدخل أربعة أرقام وهمية فقط."
            return
        }
        balanceFils = fils
        cardSuffix = digits
        dismiss()
    }
}
