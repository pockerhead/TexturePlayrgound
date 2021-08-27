//
//  Cell.swift
//  TexturePlayground
//
//  Created by Артём Балашов on 27.08.2021.
//

import AsyncDisplayKit

final class Cell: ASCellNode {
    
    let photo = ASDisplayNode()
    let label = ASTextNode()
    let secondLabel = ASTextNode()

    override func didLoad() {
        super.didLoad()
        style.preferredLayoutSize = .init(width: .init(unit: .auto, value: 1),
                                          height: .init(unit: .points, value: 100))
        addSubnode(photo)
        addSubnode(secondLabel)
        photo.backgroundColor = .black
        addSubnode(label)
        backgroundColor = .init(hue: CGFloat(arc4random_uniform(100)) / 100, saturation: 0.4, brightness: 1, alpha: 1)
        label.maximumNumberOfLines = 0
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        layer.cornerRadius = 12
        photo.layer.cornerRadius = photo.frame.height / 2
    }
    
    override func didEnterPreloadState() {
        super.didEnterPreloadState()
        label.configure(with: .body1(UUID().uuidString))
        secondLabel.configure(with: .body1(UUID().uuidString))
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        label.style.flexShrink = 1
        secondLabel.style.flexShrink = 1
        let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 2, justifyContent: .center, alignItems: .start, flexWrap: .wrap, alignContent: .center, children: [label, secondLabel])
        verticalStack.style.flexBasis = .init(unit: .auto, value: 1)
        verticalStack.style.flexShrink = 1
        photo.style.preferredSize = .init(width: 64, height: 64)
        let horizontalStack = ASStackLayoutSpec(direction: .horizontal, spacing: 8, justifyContent: .start, alignItems: .center, children: [photo, verticalStack])
        horizontalStack.style.flexGrow = 1
        return ASInsetLayoutSpec(insets: .init(top: 8, left: 16, bottom: 8, right: 16), child: horizontalStack).styled({
            $0.flexGrow = 1
            $0.flexShrink = 1
        })
    }
}

struct DSLabel {
    
    var text: String
    var font: UIFont = .systemFont(ofSize: 10)
    var color: UIColor
    
    static func body1(_ text: String) -> DSLabel {
        .init(text: text, font: .systemFont(ofSize: 16), color: .darkText)
    }
}

extension ASTextNode {
    
    func configure(with dsLabel: DSLabel) {
        attributedText = NSAttributedString(string: dsLabel.text, attributes: [
            .font: dsLabel.font,
            .foregroundColor: dsLabel.color
        ])
    }
}
