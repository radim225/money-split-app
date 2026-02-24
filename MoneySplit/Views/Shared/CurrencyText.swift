import SwiftUI

struct CurrencyText: View {
    let cents: Int
    let currencyCode: String
    var font: Font = .body
    var colorCoded: Bool = false

    var body: some View {
        Text(CurrencyFormatter.format(cents: abs(cents), currencyCode: currencyCode))
            .font(font)
            .foregroundStyle(textColor)
    }

    private var textColor: Color {
        guard colorCoded else { return .primary }
        if cents > 0 { return .green }
        if cents < 0 { return .red }
        return .secondary
    }
}

#Preview {
    VStack(spacing: 8) {
        CurrencyText(cents: 1250, currencyCode: "USD")
        CurrencyText(cents: 1250, currencyCode: "USD", colorCoded: true)
        CurrencyText(cents: -750, currencyCode: "EUR", colorCoded: true)
        CurrencyText(cents: 0, currencyCode: "USD", colorCoded: true)
    }
    .padding()
}
