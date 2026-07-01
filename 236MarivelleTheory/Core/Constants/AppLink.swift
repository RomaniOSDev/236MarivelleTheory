import Foundation

enum AppLink {
    case privacyPolicy
    case termsOfUse

    var url: URL? {
        switch self {
        case .privacyPolicy:
            URL(string: "https://marivelletheory236.site/privacy/311")
        case .termsOfUse:
            URL(string: "https://marivelletheory236.site/terms/311")
        }
    }
}
