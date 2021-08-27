//
//  ViewController.swift
//  TexturePlayground
//
//  Created by Артём Балашов on 27.08.2021.
//

import UIKit
import AsyncDisplayKit

class ViewController: ASDKViewController<ASCollectionNode> {
    
    override init() {
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))])
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = ASCollectionNode(collectionViewLayout: layout)
        super.init(node: collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = .white
        node.delegate = self
        node.dataSource = self
        node.automaticallyManagesSubnodes = true
    }


}

extension ViewController: ASCollectionDataSource, ASCollectionDelegate {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        {
            Cell()
        }
    }
}
