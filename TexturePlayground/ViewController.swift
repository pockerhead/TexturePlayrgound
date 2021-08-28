//
//  ViewController.swift
//  TexturePlayground
//
//  Created by Артём Балашов on 27.08.2021.
//

import UIKit
import AsyncDisplayKit
import Combine

//Mimkk0fjy0hb7qyAZ0iHnsTJUqrTXxkJ
let apiKey: [UInt8] = [0x4a,0x6b,0x78,0x58,0x54,0x72,0x71,0x55,0x4a,0x54,0x73,0x6e,0x48,0x69,0x30,0x5a,0x41,0x79,0x71,0x37,0x62,0x68,0x30,0x79,0x6a,0x66,0x30,0x6b,0x6b,0x6d,0x69,0x4d]
let proxy = UUID().uuidString

var data2: String {
    let data2 = apiKey
        .reversed()
        .reduce(Data.init(capacity: apiKey.count)) { acc, next in
        var acc = acc
        acc.append(next)
        return acc
    }
    return String(data: data2, encoding: .utf8)!
}

class ViewController: ASDKViewController<ASCollectionNode> {
    
    var cancellables = Set<AnyCancellable>()
    var page = 0
    var isLoading = false
    
    var data: [Sticker] = []
    
    override init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(node: ASCollectionNode(collectionViewLayout: layout))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "123123123"
        navigationController?.navigationBar.prefersLargeTitles = true
        node.backgroundColor = .white
        node.delegate = self
        node.placeholderEnabled = true
        node.view.delaysContentTouches = false
        node.dataSource = self
        node.automaticallyManagesSubnodes = true
    }
    
    func modelIdentifierForElement(at indexPath: IndexPath, in collectionNode: ASCollectionNode) -> String? {
        return data[indexPath.item].images?.fixed_height?.url
    }
    
    func getRandomStickers(count: Int, context: ASBatchContext? = nil) {
        var comps = URLComponents(string: "https://api.giphy.com/v1/stickers/random")!
        comps.queryItems = [
            .init(name: "api_key", value: data2),
            .init(name: "random_id", value: proxy)
        ]
        var request = URLRequest(url: comps.url!)
        request.httpMethod = "GET"
        let publishers = (0...count).map({ _ in
            URLSession.shared.dataTaskPublisher(for: request)
                .map({ $0.data })
                .decode(type: BasicResponse<Sticker>.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .compactMap({ $0.data })
        })
        Publishers.MergeMany(publishers)
            .collect()
            .sink { compl in
                print(compl)
            } receiveValue: { stickers in
                let count = self.data.count
                self.data.append(contentsOf: stickers)
                context?.completeBatchFetching(true)
                
                self.node.performBatch(animated: true) {
                    self.node.insertItems(at: (count...(count + stickers.count - 1))
                                        .map({ IndexPath(item: $0, section: 0)}))
                }
            }
            .store(in: &cancellables)

    }

    func getStickers(context: ASBatchContext? = nil) {
        page += 1
        var comps = URLComponents(string: "https://api.giphy.com/v1/stickers/trending")!
        comps.queryItems = [
            .init(name: "api_key", value: data2),
            .init(name: "limit", value: "20"),
            .init(name: "offset", value: "\(page)"),
            .init(name: "random_id", value: proxy)
        ]
        var request = URLRequest(url: comps.url!)
        request.httpMethod = "GET"
        URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: BasicResponse<[Sticker]>.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .map({ $0.data ?? [] })
            .sink(receiveCompletion: { compl in
                
            }, receiveValue: { stickers in
                self.data.append(contentsOf: stickers)
                context?.completeBatchFetching(true)
            })
            .store(in: &cancellables)
    }

}

struct BasicResponse<T: Codable>: Codable {
    var data: T?
}

struct Sticker: Codable {
    var title: String?
    var images: Images?
    var type: String?
}

struct Images: Codable {
    
    var fixed_height: FixedHeight?
    
    struct FixedHeight: Codable {
        var url: String?
    }
}

extension ViewController: ASCollectionDataSource, ASCollectionDelegate {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        data[indexPath.item].title = (data[indexPath.item].title ?? "") + (data[indexPath.item].title ?? "")
        collectionNode.performBatch(animated: true) {
            collectionNode.reloadItems(at: [indexPath])
        } completion: { _ in
            
        }

    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        {
            let cell = Cell()
            if let data = self.data[safe: indexPath.item] {
                let title = data.title ?? ""
                cell.placeholderEnabled = true
                cell.label.configure(with: .body1(title))
                cell.secondLabel.configure(with: .body1(data.type ?? ""))
                cell.url = data.images?.fixed_height?.url ?? ""
                cell.style.preferredLayoutSize = .init(width: .init(unit: .fraction, value: 1), height: .init(unit: .auto, value: 1))
            }
            return cell
        }
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        true
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        getRandomStickers(count: 100, context: context)
    }
}

public extension Array {
    subscript(safe index: Index) -> Element? {
        if indices.contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}
