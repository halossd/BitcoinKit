//
//  BitcoinAPI.swift
//  BitcoinKit
//
//  Created by cc on 2019/7/3.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import UIKit
import SwiftyJSON

public enum APIResult<ResultType: Codable> {
    case success(ResultType?)
    case failure(Error?)

    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

class BitcoinAPI {
    private let endpoint: ApiEndPoint.ChainSo

    public init(network: Network) {
        self.endpoint = ApiEndPoint.ChainSo(network: network)
    }

    public func getAddressDetail<ResultType>(address: Address, completion: ((APIResult<ResultType>) -> Void)?) {
        let url = endpoint.getAddressURL(with: address)
        print(url)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else {
                print("data is nil.")
                return
            }

            do {
                let response = try JSONDecoder().decode(SmartResponseObject<ResultType>.self, from: data)
                completion?(.success(response.address))
            } catch {
                completion?(.failure(error))
            }

        }
        task.resume()
    }

}

public struct ResponseObject<ResultType: Codable>: Codable {
    let status: String
    let data: ResultType?
    let code: Int?
    let message: String?
}

public struct SmartResponseObject<ResultType: Codable>: Codable {
    let success: Bool
    let address: ResultType?
}

public struct SmartUtxoObject: Codable {
    let success: Bool
    let paging: JSON
    let unspent: [SmartUtxoModel]
}
