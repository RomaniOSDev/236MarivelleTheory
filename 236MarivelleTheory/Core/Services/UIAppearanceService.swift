import UIKit

enum UIAppearanceService {
    static func configure() {
        let primary = UIColor(named: "AppTextPrimary") ?? .white
        let secondary = UIColor(named: "AppTextSecondary") ?? .white
        let surface = UIColor(named: "AppSurface") ?? .darkGray
        let accent = UIColor(named: "AppPrimary") ?? .yellow

        UISegmentedControl.appearance().selectedSegmentTintColor = accent
        UISegmentedControl.appearance().backgroundColor = surface
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: primary],
            for: .selected
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: secondary],
            for: .normal
        )

        UITextField.appearance().textColor = primary
        UITextField.appearance().tintColor = accent
        UILabel.appearance(whenContainedInInstancesOf: [UITextField.self]).textColor = secondary

        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = primary
        UITableView.appearance().backgroundColor = .clear
    }
}
