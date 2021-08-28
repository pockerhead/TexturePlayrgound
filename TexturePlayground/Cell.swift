//
//  Cell.swift
//  TexturePlayground
//
//  Created by Артём Балашов on 27.08.2021.
//

import AsyncDisplayKit

final class Cell: ASCellNode {
    
    var someView: UIView!
    
    let photo = ASNetworkImageNode()
    let label = ASTextNode()
    let secondLabel = ASTextNode()
    var text: String = ""
    let separator = ASDisplayNode()
    var subText: String = ""
    var url: String = ""

    override func didLoad() {
        super.didLoad()
        photo.defaultImage = .checkmark
        photo.view.backgroundColor = .clear
        someView = UIView()
        view.addSubview(someView)
        addSubnode(separator)
        separator.backgroundColor = .separator
        photo.contentMode = .scaleAspectFit
        style.preferredLayoutSize = .init(width: .init(unit: .fraction, value: 1),
                                          height: .init(unit: .auto, value: 1))
        addSubnode(photo)
//        someView.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        addSubnode(secondLabel)
        photo.backgroundColor = .black
        addSubnode(label)
        backgroundColor = .systemBackground
        label.maximumNumberOfLines = 0
    }
    
    override func layout() {
        super.layout()
        someView.frame = bounds
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        photo.layer.cornerRadius = photo.frame.height / 2
    }
    
    override func didEnterPreloadState() {
        super.didEnterPreloadState()
        photo.setURL(.init(string: url), resetToDefault: true)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 2, justifyContent: .center, alignItems: .start, flexWrap: .noWrap, alignContent: .spaceBetween, children: [label, secondLabel])
        verticalStack.style.flexShrink = 1
        photo.style.preferredSize = .init(width: 64, height: 64)
        let horizontalStack = ASStackLayoutSpec(direction: .horizontal, spacing: 8, justifyContent: .start, alignItems: .center, children: [photo, verticalStack])
        let horizontalInsets = ASInsetLayoutSpec(insets: .init(top: 8, left: 0, bottom: 8, right: 16), child: horizontalStack)
        separator.style.preferredLayoutSize = .init(width: .init(unit: .fraction, value: 1), height: .init(unit: .points, value: 1))
        let anotherVertical = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .start, children: [horizontalInsets, separator])
        return ASInsetLayoutSpec(insets: .init(top: 0, left: 16, bottom: 0, right: 0), child: anotherVertical)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.3) {[self] in
//            transform = CATransform3DMakeScale(0.9, 0.9, 1)
//        }
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.2) {[self] in
//            transform = CATransform3DIdentity
//        }
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.2) {[self] in
//            transform = CATransform3DIdentity
//        }
//    }
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
