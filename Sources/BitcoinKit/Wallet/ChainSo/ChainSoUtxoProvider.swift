//
//  ChainSoUtxoProvider.swift
//  BitcoinKit
//
//  Created by cc on 2019/7/4.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

class ChainSoUtxoProvider: UtxoProvider {

    private let endpoint: ApiEndPoint.ChainSo
    private let dataStore: BitcoinKitDataStoreProtocol

    public init(network: Network, dataStore: BitcoinKitDataStoreProtocol) {
        self.endpoint = ApiEndPoint.ChainSo(network: network)
        self.dataStore = dataStore
    }

    func reload(address: Address, completion: ((APIResult<ChainSoUtxoData>) -> Void)? = nil) {
        let url = endpoint.utxoURL(with: address)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else {
                completion?(.failure(NSError(domain: "data is nil", code: 10_010, userInfo: nil)))
                return
            }

            do {
                let response = try JSONDecoder().decode(ResponseObject<ChainSoUtxoData>.self, from: data)
                completion?(.success(response.data))
                UserDefaults.bitcoinKit.setData(data, forKey: .utxos)
//                self?.dataStore.setData(data, forKey: .utxos)
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

        guard let response = try? JSONDecoder().decode(ResponseObject<ChainSoUtxoData>.self, from: data) else {
            print("data cannot be decoded to response")
            return []
        }
        let txs = response.data?.txs
        if txs!.isEmpty {
            return []
        }
        return txs!.asUtxos()
    }

}

extension Sequence where Element == ChainSoUtxoModel {
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
