import SwiftUI

@main
struct DemoWalletApp: App {
    var body: some Scene {
        WindowGroup {
            WalletView()
                .environment(\.layoutDirection, .rightToLeft)
                .preferredColorScheme(.light)
        }
    }
}

struct WalletView: View {
    @AppStorage("demoBalanceFils") private var balanceFils = 1_000_000
    @AppStorage("demoCardSuffix") private var cardSuffix = "1234"
    @State private var editing = false
    @State private var showInfo = false
    private let red = Color(red: 0.89, green: 0.02, blue: 0.22)
    private let ink = Color(red: 0.32, green: 0.31, blue: 0.30)

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
            Label("للمزح فقط — رصيد وهمي وغير صالح للدفع", systemImage: "exclamationmark.shield")
                .font(.caption.bold())
                .frame(maxWidth: .infinity).padding(.vertical, 9)
                .foregroundStyle(red).background(Color.white)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    stories
                    accountCard
                    HStack(spacing: 6) {
                        Capsule().fill(red).frame(width: 16, height: 3)
                        Capsule().fill(.gray.opacity(0.3)).frame(width: 14, height: 3)
                        Capsule().fill(.gray.opacity(0.3)).frame(width: 14, height: 3)
                    }
                    .padding(.top, -12)
                    transferButtons
                    services
                    promotion
                    Text("نموذج مستقل وغير تابع لـ BenefitPay أو أي بنك. جميع الخدمات استعراضية فقط.")
                        .font(.caption).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center).padding(.bottom, 12)
                }
                .padding(.horizontal, 18).padding(.top, 16)
            }
            bottomBar
        }
        .foregroundStyle(ink)
        .background {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    Color(red: 0.98, green: 0.98, blue: 0.97)
                    ContourBackground().frame(height: min(proxy.size.height * 0.53, 410))
                }
                .ignoresSafeArea()
            }
        }
        .tint(red)
        .sheet(isPresented: $editing) {
            EditorView(balanceFils: $balanceFils, cardSuffix: $cardSuffix)
                .environment(\.layoutDirection, .rightToLeft).tint(red)
        }
        .alert("عرض تجريبي فقط", isPresented: $showInfo) {
            Button("حسنًا", role: .cancel) { }
        } message: {
            Text("هذه الواجهة للمزح فقط. لا يوجد دفع أو تحويل أو رمز QR صالح أو إيصال حقيقي.")
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("D").font(.system(size: 33, weight: .heavy, design: .rounded))
                .italic().foregroundStyle(red).accessibilityLabel("شعار النموذج التجريبي")
            Text("مرحبًا بعودتك!").font(.title3.bold()).lineLimit(1).minimumScaleFactor(0.7)
            Spacer(minLength: 4)
            Button { editing = true } label: { Image(systemName: "plus").font(.title2) }
                .accessibilityLabel("تعديل الرصيد والبطاقة")
            Button { showInfo = true } label: { Image(systemName: "magnifyingglass").font(.title3) }
                .accessibilityLabel("بحث تجريبي")
            Button { showInfo = true } label: { Image(systemName: "envelope").font(.title3) }
                .accessibilityLabel("رسائل تجريبية")
        }
        .foregroundStyle(red)
    }

    private var stories: some View {
        HStack(alignment: .top, spacing: 8) {
            story("اكتشف", icon: "gift", highlighted: false)
            story("تنويه", icon: "bell.badge", highlighted: true)
            story("الخدمات", icon: "square.grid.2x2", highlighted: true)
            story("دليلك", icon: "book.closed", highlighted: true)
            story("نصائح", icon: "lightbulb", highlighted: true)
        }
    }

    private func story(_ title: String, icon: String, highlighted: Bool) -> some View {
        Button { showInfo = true } label: {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 25, weight: .light))
                    .foregroundStyle(red).frame(maxWidth: .infinity).frame(height: 55)
                    .background(.white.opacity(0.85), in: Circle())
                    .padding(4)
                    .overlay(Circle().stroke(highlighted ? red : .gray.opacity(0.35), lineWidth: 1.5))
                Text(title).font(.caption).foregroundStyle(ink)
            }.frame(maxWidth: .infinity)
        }.buttonStyle(.plain)
    }

    private var accountCard: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.title2).foregroundStyle(.white).frame(width: 42, height: 42)
                    .background(Color(red: 0.20, green: 0.21, blue: 0.22), in: RoundedRectangle(cornerRadius: 7))
                VStack(alignment: .leading, spacing: 6) {
                    Text("حساب تجريبي").font(.headline)
                    Text("DEMO •••• \(cardSuffix)")
                        .font(.caption.monospaced()).foregroundStyle(.secondary)
                        .environment(\.layoutDirection, .leftToRight)
                }
                Spacer(minLength: 2)
                Image(systemName: "star").font(.body)
                Text("المفضلة").font(.subheadline)
            }
            Button { editing = true } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(amount) BHD")
                        .font(.system(size: 24, weight: .bold)).lineLimit(1).minimumScaleFactor(0.5)
                        .environment(\.layoutDirection, .leftToRight)
                    Text("رصيد وهمي · اضغط للتعديل").font(.caption)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain).foregroundStyle(red)
            Divider().padding(.top, 8)
            Button { showInfo = true } label: {
                Label("عرض QR تجريبي", systemImage: "qrcode.viewfinder")
                    .font(.headline).frame(maxWidth: .infinity)
            }
        }
        .padding(20).background(.white, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 18, y: 10)
    }

    private var transferButtons: some View {
        HStack(spacing: 14) {
            Button { showInfo = true } label: {
                Label("طلب الأموال", systemImage: "arrow.down.left")
                    .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 17)
            }
            .background(red.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(red, lineWidth: 1))
            Button { showInfo = true } label: {
                Label("إرسال الأموال", systemImage: "arrow.up.right")
                    .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 17)
            }
            .foregroundStyle(.white)
            .background(LinearGradient(colors: [red, Color(red: 1, green: 0.32, blue: 0.26)], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 15))
        }
    }

    private var services: some View {
        VStack(spacing: 20) {
            HStack {
                Text("الخدمات").font(.title2.bold())
                Spacer()
                Button("مشاهدة الكل") { showInfo = true }.font(.subheadline.bold())
            }
            HStack(alignment: .top, spacing: 14) {
                service("تحويل سريع+", icon: "arrow.up.forward.square")
                service("امسح للدفع", icon: "viewfinder")
                service("تحويل سريع", icon: "arrow.left.arrow.right")
                service("تقسيم الدفع", icon: "rectangle.split.2x1")
            }
        }.padding(.top, 6)
    }

    private func service(_ title: String, icon: String) -> some View {
        Button { showInfo = true } label: {
            VStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 31, weight: .ultraLight))
                    .foregroundStyle(red).frame(maxWidth: .infinity).frame(height: 76)
                    .background(.white, in: RoundedRectangle(cornerRadius: 17))
                    .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
                Text(title).font(.caption).foregroundStyle(ink).lineLimit(2)
                    .multilineTextAlignment(.center).frame(minHeight: 28, alignment: .top)
            }.frame(maxWidth: .infinity)
        }.buttonStyle(.plain)
    }

    private var promotion: some View {
        HStack(spacing: 18) {
            Image(systemName: "creditcard.fill").font(.system(size: 52, weight: .light))
                .rotationEffect(.degrees(-14)).foregroundStyle(.white.opacity(0.6))
            VStack(alignment: .leading, spacing: 8) {
                Text("كل شيء هنا تجريبي").font(.title3.bold())
                Text("عدّل الرصيد والبطاقة من زر +").font(.subheadline)
                Text("للمزح فقط").font(.caption.bold())
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(.white.opacity(0.16), in: Capsule())
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white).padding(22).frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [Color(red: 0.04, green: 0.13, blue: 0.32), Color(red: 0.08, green: 0.32, blue: 0.64)], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 22))
    }

    private var bottomBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            tab("الرئيسية", icon: "house", selected: true)
            tab("المطالبات", icon: "checkmark.rectangle", selected: false)
            Button { showInfo = true } label: {
                VStack(spacing: 7) {
                    Image(systemName: "viewfinder").font(.title2)
                        .foregroundStyle(.white).frame(width: 52, height: 52)
                        .background(red, in: Circle())
                        .shadow(color: red.opacity(0.25), radius: 7, y: 3)
                    Text("امسح للدفع").font(.system(size: 10)).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity)
            }
            tab("المعاملات", icon: "rectangle.on.rectangle", selected: false)
            Button { editing = true } label: {
                VStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3").font(.title3)
                    Text("تعديل").font(.system(size: 10))
                }.foregroundStyle(.secondary).frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8).padding(.top, 10).padding(.bottom, 8)
        .background(.white.shadow(.drop(color: .black.opacity(0.04), radius: 8, y: -3)))
    }

    private func tab(_ title: String, icon: String, selected: Bool) -> some View {
        Button {
            if !selected { showInfo = true }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.system(size: 10))
            }
            .foregroundStyle(selected ? red : .gray).frame(maxWidth: .infinity)
        }
    }
}

struct ContourBackground: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.88, green: 0.85, blue: 0.79)))
            for index in 0..<34 {
                let offset = CGFloat(index) * 15 - 220
                var path = Path()
                path.move(to: CGPoint(x: offset, y: size.height + 80))
                path.addCurve(to: CGPoint(x: size.width + 100, y: offset * 0.65),
                              control1: CGPoint(x: size.width * 0.30 + offset, y: size.height * 0.12),
                              control2: CGPoint(x: size.width * 0.70, y: offset - 90))
                context.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 1)
            }
        }
        .mask(LinearGradient(colors: [.black, .black, .clear], startPoint: .top, endPoint: .bottom))
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
                        .font(.headline).foregroundStyle(.red)
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
