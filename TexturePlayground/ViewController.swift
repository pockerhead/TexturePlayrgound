//
//  ViewController.swift
//  TexturePlayground
//
//  Created by Артём Балашов on 27.08.2021.
//

import UIKit
import AsyncDisplayKit
import Combine

let apiKey = "Mimkk0fjy0hb7qyAZ0iHnsTJUqrTXxkJ"
let proxy = UUID().uuidString

class ViewController: ASDKViewController<ASCollectionNode> {
    
    var cancellables = Set<AnyCancellable>()
    var page = 0
    var isLoading = false
    
    var data: [Sticker] = []
    
    override init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = ASCollectionNode(collectionViewLayout: layout)
        super.init(node: collectionView)
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
        node.dataSource = self
        node.automaticallyManagesSubnodes = true
    }
    
    func getRandomStickers(count: Int, context: ASBatchContext? = nil) {
        var comps = URLComponents(string: "https://api.giphy.com/v1/stickers/random")!
        comps.queryItems = [
            .init(name: "api_key", value: apiKey),
            .init(name: "limit", value: "20"),
            .init(name: "offset", value: "\(page)"),
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
                
                self.node.performBatch(animated: false) {
                    self.node.insertItems(at: (count...(count + stickers.count - 1))
                                        .map({ IndexPath(item: $0, section: 0)}))
                } completion: { _ in
                    
                }
            }
            .store(in: &cancellables)

    }

    func getStickers(context: ASBatchContext? = nil) {
        page += 1
        var comps = URLComponents(string: "https://api.giphy.com/v1/stickers/trending")!
        comps.queryItems = [
            .init(name: "api_key", value: apiKey),
            .init(name: "limit", value: "20"),
            .init(name: "offset", value: "\(page)"),
            .init(name: "random_id", value: proxy)
        ]
        var request = URLRequest(url: comps.url!)
        request.httpMethod = "GET"
        print(request.url?.absoluteString)
        URLSession.shared.dataTaskPublisher(for: request)
            .map({ $0.data })
            .decode(type: BasicResponse<[Sticker]>.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .map({ $0.data ?? [] })
            .sink(receiveCompletion: { compl in
                
            }, receiveValue: { stickers in
                let count = self.data.count
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
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        {
            let cell = Cell()
            if let data = self.data[safe: indexPath.item] {
                cell.text = data.title ?? ""
                cell.subText = data.type ?? ""
                cell.url = data.images?.fixed_height?.url ?? ""
            }
            return cell
        }
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        true
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        getRandomStickers(count: 200, context: context)
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
