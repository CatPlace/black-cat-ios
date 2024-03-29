//
//  WebViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2023/01/05.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    
    // MARK: - Properties
    var linkString: String
    
    
    // MARK: - Initializer
    init(linkString: String) {
        self.linkString = linkString
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        loadWebView()
        appendNavigationLeftBackButton(color: .black)
    }
    
    func loadWebView() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard  let url = URL(string: self?.linkString ?? "") else {
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
                return
            }
            let request = URLRequest(url: url)
            
            DispatchQueue.main.async {
                self?.webView.load(request)
            }
        }
    }
    
    // MARK: - UIComponents
    lazy var webView: WKWebView = {
        $0.uiDelegate = self
        $0.navigationDelegate = self
        return $0
    }(WKWebView(frame: .zero))
    
    var indicator = UIActivityIndicatorView()
    
    func setUI() {
        [webView, indicator].forEach { view.addSubview($0) }
        
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        indicator.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
}
