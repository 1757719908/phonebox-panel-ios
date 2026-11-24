import UIKit
import WebKit

final class SettingsViewController: UIViewController {

    var onSave: (() -> Void)?

    private let field: UITextField = {
        let t = UITextField()
        t.borderStyle = .roundedRect
        t.autocapitalizationType = .none
        t.autocorrectionType = .no
        t.keyboardType = .URL
        t.returnKeyType = .done
        t.placeholder = "http://192.168.1.10:18080"
        return t
    }()

    private let alwaysOn = UISwitch()
    private let hideStatus = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "面板设置"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(save))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))

        field.text = Store.urlString
        alwaysOn.isOn = Store.alwaysOn
        hideStatus.isOn = Store.hideStatusBar

        buildLayout()
    }

    private func buildLayout() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        view.addSubview(scroll)

        stack.addArrangedSubview(makeLabel("面板地址（电脑端 PhoneBox 的局域网地址）"))
        stack.addArrangedSubview(field)
        stack.addArrangedSubview(makeLabel("同一 WiFi 下填 电脑IP:端口，例如 192.168.1.10:18080"))

        stack.addArrangedSubview(makeRow(title: "保持屏幕常亮", control: alwaysOn))
        stack.addArrangedSubview(makeRow(title: "隐藏状态栏（全屏）", control: hideStatus))

        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除网页缓存", for: .normal)
        clearButton.addTarget(self, action: #selector(clearCache), for: .touchUpInside)
        stack.addArrangedSubview(clearButton)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40)
        ])
    }

    private func makeLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        return l
    }

    private func makeRow(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)
        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        row.backgroundColor = .secondarySystemGroupedBackground
        row.layer.cornerRadius = 10
        return row
    }

    @objc private func save() {
        let raw = field.text ?? ""
        guard let url = Store.normalizedURL(from: raw) else {
            let alert = UIAlertController(title: "地址无效", message: "请填写完整地址，例如 192.168.1.10:18080", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default))
            present(alert, animated: true)
            return
        }
        Store.urlString = url.absoluteString
        Store.alwaysOn = alwaysOn.isOn
        Store.hideStatusBar = hideStatus.isOn
        onSave?()
        dismiss(animated: true)
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func clearCache() {
        let types: Set<String> = [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache,
                                  WKWebsiteDataTypeCookies, WKWebsiteDataTypeOfflineWebApplicationCache]
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast) { [weak self] in
            let alert = UIAlertController(title: "已清除", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default))
            self?.present(alert, animated: true)
        }
    }
}
