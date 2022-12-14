//
//  FontExampleViewController.swift
//  BlackCat
//
//  Created by 김지훈 on 2022/12/04.
//

import UIKit

class FontExampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let pretendard: [UIFont.FontType.Pretentdard] = [.regular, .bold, .extraBold, .extraLight, .light, .medium, .semiBold, .thin]
        let heirOfLight: [UIFont.FontType.HeirOfLight] = [.regular, .bold]
        let didot: [UIFont.FontType.Didot] = [.regular, .bold, .italic, .title]
        
        let VStackView: UIStackView = {
            let v = UIStackView()
            v.axis = .vertical
            v.distribution = .fillEqually
           return v
        }()
        
        view.addSubview(VStackView)
        VStackView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        pretendard.forEach {
            let l = UILabel()
            configure(l, text: $0.rawValue)
            l.font = .pretendardFont(style: $0)
        }
        
        heirOfLight.forEach {
            let l = UILabel()
            configure(l, text: $0.rawValue)
            l.font = .heirOfLightFont(style: $0)
        }
        
        didot.forEach {
            let l = UILabel()
            configure(l, text: $0.rawValue)
            l.font = .didotFont(style: $0)
        }
        
        func configure(_ sender: UILabel, text: String) {
            VStackView.addArrangedSubview(sender)
            sender.text = text
        }
    }
}
