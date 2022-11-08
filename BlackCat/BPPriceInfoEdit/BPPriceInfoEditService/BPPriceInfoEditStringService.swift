//
//  BPPriceInfoEditStringService.swift
//  BlackCat
//
//  Created by Hamlit Jason on 2022/11/06.
//

import Foundation

protocol BPPriceInfoEditStringServiceProtocol {
    func convertToArray(_ text: String)
}

final class BPPriceInfoEditStringService: BPPriceInfoEditStringServiceProtocol {
    
    func convertToArray(_ text: String) {
        print("✅✅✅✅✅✅✅✅✅✅✅")
        print(text)
        
        let rawData = text.components(separatedBy: ["{", "}"])
        
        print("💕 \(rawData)")
        
        // result is DTO
        var result = [String]()
        
        rawData.forEach { data in
            if data.contains("NSAttachment") {
                
            } else {
//                result.append(data)
            }
        }
    }
}

/*
 이미지
 문자
 줄바꿈
 줄바꿈
 문자
 이미지
 */

/**
 ￼{
     NSAttachment = "<NSTextAttachment: 0x6000029fa290>";
     NSFont = "<UICTFont: 0x7fcfcd04b6d0> font-family: \".SFUI-Semibold\"; font-weight: bold; font-style: normal; font-size: 16.00pt";
 }
 {
     NSFont = "<UICTFont: 0x7fcfcd04b6d0> font-family: \".SFUI-Semibold\"; font-weight: bold; font-style: normal; font-size: 16.00pt";
 }
 문자 입니다.


 문자{
     NSFont = "<UICTFont: 0x7fcfcd04b6d0> font-family: \".SFUI-Semibold\"; font-weight: bold; font-style: normal; font-size: 16.00pt";
     NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 0, LineBreakMode 0, Tabs (\n    28L,\n    56L,\n    84L,\n    112L,\n    140L,\n    168L,\n    196L,\n    224L,\n    252L,\n    280L,\n    308L,\n    336L\n), DefaultTabInterval 0, Blocks (\n), Lists (\n), BaseWritingDirection 0, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0 LineBreakStrategy 0 PresentationIntents (\n) ListIntentOrdinal 0 CodeBlockIntentLanguageHint ''";
 }￼{
     NSAttachment = "<NSTextAttachment: 0x600002985650>";
     NSParagraphStyle = "Alignment 4, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 0, LineBreakMode 0, Tabs (\n    28L,\n    56L,\n    84L,\n    112L,\n    140L,\n    168L,\n    196L,\n    224L,\n    252L,\n    280L,\n    308L,\n    336L\n), DefaultTabInterval 0, Blocks (\n), Lists (\n), BaseWritingDirection 0, HyphenationFactor 0, TighteningForTruncation NO, HeaderLevel 0 LineBreakStrategy 0 PresentationIntents (\n) ListIntentOrdinal 0 CodeBlockIntentLanguageHint ''";
 }
 */

/* NOTE: - server 설계
 [POST]
 "0": string
 "1": image
 "2": "A"
 
 [GET]
 "0": 안녕
 "1": imageUrlString(https:/ .. )
 "2": 나에요.
 */
