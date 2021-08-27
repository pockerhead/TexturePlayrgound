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
    var subText: String = ""
    var url: String = ""

    override func didLoad() {
        super.didLoad()
        someView = UIView()
        photo.contentMode = .scaleAspectFit
        style.preferredLayoutSize = .init(width: .init(unit: .fraction, value: 1),
                                          height: .init(unit: .auto, value: 1))
        addSubnode(photo)
        someView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(someView)
        addSubnode(secondLabel)
        photo.backgroundColor = .black
        addSubnode(label)
        backgroundColor = .init(hue: CGFloat(arc4random_uniform(100)) / 100, saturation: 0.4, brightness: 1, alpha: 1)
        label.maximumNumberOfLines = 0
    }
    
    override func layout() {
        super.layout()
        someView.frame = bounds
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        layer.cornerRadius = 12
    }
    
    override func didEnterPreloadState() {
        super.didEnterPreloadState()
        label.configure(with: .body1(text))
        secondLabel.configure(with: .body1(subText))
        photo.setURL(.init(string: url), resetToDefault: true)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 2, justifyContent: .center, alignItems: .start, flexWrap: .wrap, alignContent: .center, children: [label, secondLabel])
        photo.style.preferredSize = .init(width: 64, height: 64)
        let horizontalStack = ASStackLayoutSpec(direction: .horizontal, spacing: 8, justifyContent: .start, alignItems: .center, children: [photo, verticalStack])
        return ASInsetLayoutSpec(insets: .init(top: 8, left: 16, bottom: 8, right: 16), child: horizontalStack)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3) {[self] in
            transform = CATransform3DMakeScale(0.9, 0.9, 1)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {[self] in
            transform = CATransform3DIdentity
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2) {[self] in
            transform = CATransform3DIdentity
        }
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
