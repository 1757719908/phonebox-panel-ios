import UIKit
import WebKit

final class PanelViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private let webView: WKWebView = {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        if #available(iOS 14.0, *) {
            cfg.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        cfg.preferences.javaScriptCanOpenWindowsAutomatically = true
        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.isOpaque = false
        wv.backgroundColor = .black
        wv.scrollView.backgroundColor = .black
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        wv.allowsBackForwardNavigationGestures = true
        return wv
    }()

    private let gearButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        b.tintColor = .white
        b.alpha = 0.25
        return b
    }()

    private let hintLabel: UILabel = {
        let l = UILabel()
        l.text = "还没设置面板地址\n点右上角齿轮填入电脑 PhoneBox 地址\n例如 192.168.1.10:18080"
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.font = .systemFont(ofSize: 15, weight: .regular)
        return l
    }()

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.text = "连接失败，检查电脑端服务 / 局域网是否同网段"
        l.numberOfLines = 0
        l.textAlignment = .center
        l.textColor = UIColor.systemOrange
        l.font = .systemFont(ofSize: 14)
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        applyScreenSettings()
        loadIfNeeded()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Store.urlString == nil {
            presentSettings()
        }
    }

    private func setupViews() {
        [webView, hintLabel, errorLabel, gearButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        gearButton.addTarget(self, action: #selector(presentSettings), for: .touchUpInside)
        webView.navigationDelegate = self
        webView.uiDelegate = self

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            gearButton.widthAnchor.constraint(equalToConstant: 44),
            gearButton.heightAnchor.constraint(equalToConstant: 44),
            gearButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            gearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),

            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hintLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            errorLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.85)
        ])
    }

    private func applyScreenSettings() {
        UIApplication.shared.isIdleTimerDisabled = Store.alwaysOn
        setNeedsStatusBarAppearanceUpdate()
    }

    override var prefersStatusBarHidden: Bool { Store.hideStatusBar }

    private func loadIfNeeded() {
        guard let raw = Store.urlString, let url = Store.normalizedURL(from: raw) else {
            hintLabel.isHidden = false
            return
        }
        hintLabel.isHidden = true
        errorLabel.isHidden = true
        webView.load(URLRequest(url: url))
    }

    @objc private func appWillEnterForeground() {
        applyScreenSettings()
        if webView.url == nil {
            loadIfNeeded()
        }
    }

    @objc private func presentSettings() {
        let vc = SettingsViewController()
        vc.onSave = { [weak self] in
            guard let self = self else { return }
            self.applyScreenSettings()
            self.loadIfNeeded()
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        errorLabel.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        errorLabel.isHidden = true
    }

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}
