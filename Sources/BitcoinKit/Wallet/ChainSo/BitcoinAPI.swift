//
//  BitcoinAPI.swift
//  BitcoinKit
//
//  Created by cc on 2019/7/3.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import UIKit
import SwiftyJSON

class BitcoinAPI {
    private let endpoint: ApiEndPoint.ChainSo

    public init(network: Network) {
        self.endpoint = ApiEndPoint.ChainSo(network: network)
    }

    public func getAddressDetail(address: Address, completion: ((ResponseData) -> Void)?) {
        let url = endpoint.getAddressURL(with: address)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else {
                print("data is nil.")
                completion?(ResponseData(status: "failed", data: nil, code: nil, message: nil))
                return
            }

            guard let response = try? JSONDecoder().decode(ResponseData.self, from: data) else {
                print("解析失败")
                return
            }

            completion?(response)

        }
        task.resume()
    }

}

public struct ResponseData: Codable {
    let status: String
    let data: JSON?
    let code: Int?
    let message: String?
}
