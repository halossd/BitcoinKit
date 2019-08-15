//
//  ChainSoUtxoProvider.swift
//  BitcoinKit
//
//  Created by cc on 2019/7/4.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation
import SwiftyJSON

public class ChainSoUtxoProvider: UtxoProvider {
    public func reload(addresses: [Address], completion: (([UnspentTransaction]) -> Void)?) {

    }

    private let endpoint: ApiEndPoint.ChainSo
    private let dataStore: BitcoinKitDataStoreProtocol

    public init(network: Network, dataStore: BitcoinKitDataStoreProtocol) {
        self.endpoint = ApiEndPoint.ChainSo(network: network)
        self.dataStore = dataStore
    }

    public func reload(address: Address, completion: ((APIResult<SmartUtxoObject>) -> Void)? = nil) {
        let url = endpoint.utxoURL(with: address)
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion?(.failure(NSError(domain: "data is nil", code: 10_010, userInfo: nil)))
                return
            }

            do {
                let response = try JSONDecoder().decode(SmartUtxoObject.self, from: data)
                completion?(.success(response))
                self.dataStore.setData(data, forKey: .utxos)
            } catch {
                completion?(.failure(error))
            }
        }
        task.resume()
    }

    // List utxos
    public var cached: [UnspentTransaction] {
        guard let data = dataStore.getData(forKey: .utxos) else {
            print("data is  nil")
            return []
        }

        guard let response = try? JSONDecoder().decode(SmartUtxoObject.self, from: data) else {
            print("data cannot be decoded to response")
            return []
        }
        let txs = response.unspent
        if txs.isEmpty {
            return []
        }
        return txs.asUtxos()
    }

}

extension Sequence where Element == SmartUtxoModel {
    public func asUtxos() -> [UnspentTransaction] {
        return compactMap { $0.asUtxo() }
    }
}

public struct ChainSoUtxoData: Codable {
    public let network: String
    public let address: String
    public let txs: [ChainSoUtxoModel]?
}

public struct ChainSoUtxoModel: Codable {
    public let txid: String
    public let output_no: Int
    public let script_asm: String
    public let script_hex: String
    public let value: String
    public let confirmations: Int
    public let time: Int

    public func asUtxo() -> UnspentTransaction? {
        guard let lockingScript = Data(hex: script_hex), let txidData = Data(hex: String(txid)) else { return nil }
        let txHash: Data = Data(txidData.reversed())
        let output = TransactionOutput(value: UInt64((Double(value) ?? 0) * 100_000_000), lockingScript: lockingScript)
        let outpoint = TransactionOutPoint(hash: txHash, index: UInt32(output_no))
        return UnspentTransaction(output: output, outpoint: outpoint)
    }
}

public struct SmartUtxoModel: Codable {
    public let addresses: [String]
    public let value: String
    public let value_int: Int
    public let txid: String
    public let n: Int
    public let script_pub_key: JSON
    public let req_sigs: Int
    public let type: String
    public let confirmations: Int
    public let id: Int

    public func asUtxo() -> UnspentTransaction? {
        guard let lockingScript = Data(hex: script_pub_key["hex"].string!), let txidData = Data(hex: String(txid)) else { return nil }
        let txHash: Data = Data(txidData.reversed())
        let output = TransactionOutput(value: UInt64(value_int), lockingScript: lockingScript)
        let outpoint = TransactionOutPoint(hash: txHash, index: UInt32(n))
        return UnspentTransaction(output: output, outpoint: outpoint)
    }
}
