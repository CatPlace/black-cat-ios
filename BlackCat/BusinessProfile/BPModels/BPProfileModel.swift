//
//  BPProfileModel.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/05.
//

import Foundation

struct BPProfileModel {
    /** 타이틀 */ var title: String
    /** 설명 */ var description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

extension BPProfileModel {
    static func fetch() -> [BPProfileModel] {
        var result: [BPProfileModel] = []
        
        // MARK: - Cell 1
        let name = "이름영역입니다."
        let address = "서울시 종로"
        var model = BPProfileModel(title: "자기소개", description: address)
        
        result += [model]
        
        // MARK: - Cell 2
        let selfIntroduction = """
        Scelerisque eget leo eget et. Ut molestie arcu nunc morbi lectus. Id tellus at sed ac egestas ut. Malesuada ultricies a risus mi euismod justo, vitae, a. Orci tincidunt est diam tincidunt tempus praesent adipiscing eu amet.
        
        Mi mauris pharetra semper molestie imperdiet. Imperdiet augue et vestibulum euismod purus.
        """
        model = BPProfileModel(title: "자기소개", description: selfIntroduction)
        
        result += [model]
        
        return result
    }
}


