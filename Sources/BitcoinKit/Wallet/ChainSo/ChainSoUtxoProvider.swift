//
//  ChainSoUtxoProvider.swift
//  BitcoinKit
//
//  Created by cc on 2019/7/4.
//  Copyright © 2019 BitcoinKit developers. All rights reserved.
//

import Foundation

class ChainSoUtxoProvider {
    private let endpoint: ApiEndPoint.ChainSo

    public init(network: Network) {
        self.endpoint = ApiEndPoint.ChainSo(network: network)
    }

    func reload<ResultType>(address: Address, completion: ((APIResult<ResultType>) -> Void)? = nil) {
        let url = endpoint.utxoURL(with: address)
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else {
                print("data is nil.")
                return
            }

            do {
                let response = try JSONDecoder().decode(ResponseObject<ResultType>.self, from: data)
                completion?(.success(response.data))
            } catch {
                completion?(.failure(error))
            }
        }
        task.resume()
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
