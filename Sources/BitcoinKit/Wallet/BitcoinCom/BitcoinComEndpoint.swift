//
//  BitcoinComEndpoint.swift
//
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public struct ApiEndPoint {
    public struct BitcoinCom {
        private let baseUrl: String

        init(network: Network) {
            switch network {
            case .mainnet:
                self.baseUrl = "https://rest.bitcoin.com/v2/"
            case .testnet:
                self.baseUrl = "https://trest.bitcoin.com/v1/"
            default:
                fatalError("Bitcoin.com API is only available for Bitcoin Cash.")
            }
        }

        public func getUtxoURL(with addresses: [Address]) -> URL {
            let parameter: String = addresses.map { "\"\($0.cashaddr)\"" }.joined(separator: "")
            let url = baseUrl + "address/utxo/mxLMmp7bQUn5Y2toAZbyjjXiuNHkiPvfA7"
            return ApiEndPoint.convert(string: url)!
        }

        public func getTransactionHistoryURL(with addresses: [Address]) -> URL {
            let parameter: String = "[" + addresses.map { "\"\($0.cashaddr)\"" }.joined(separator: ",") + "]"
            let url = baseUrl + "address/transactions/\(parameter)"
            return ApiEndPoint.convert(string: url)!
        }

        public func postRawtxURL(rawtx: String) -> URL {
            let url = baseUrl + "rawtransactions/sendRawTransaction/\(rawtx)"
            return ApiEndPoint.convert(string: url)!
        }
    }

    public static func convert(string: String) -> URL? {
        guard let encoded = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: encoded)
    }

    public struct ChainSo {
        private let baseUrl = "https://chain.so/api/v2/"
        private let chain: String
        private let pushURL: String

        init(network: Network) {
            switch network {
            case .mainnet:
                self.chain = "BTC"
                self.pushURL = "https://api.smartbit.com.au/v1/blockchain/pushtx"
            case .testnet:
                self.chain = "BTCTEST"
                self.pushURL = "https://testnet-api.smartbit.com.au/v1/blockchain/pushtx"
            default:
                fatalError("Bitcoin.com API is only available for Bitcoin Cash.")
            }
        }

        public func getAddressURL(with address: Address) -> URL {
            let url = baseUrl + "get_address_balance/" + chain + "/" + address.base58 // "mxLMmp7bQUn5Y2toAZbyjjXiuNHkiPvfA7" //address.base58
            print("Request: \(url)")
            return ApiEndPoint.convert(string: url)!
        }

        public func postRawtxURL() -> URL {
            return ApiEndPoint.convert(string: pushURL)!
        }

        public func utxoURL(with address: Address) -> URL {
            let url = baseUrl + "get_tx_unspent/" + chain + "/" + address.base58 //"mxLMmp7bQUn5Y2toAZbyjjXiuNHkiPvfA7" //address.base58
            print("Request: \(url)")
            return ApiEndPoint.convert(string: url)!
        }
    }
}

enum BitcoinComApiInitializationError: Error {
    case invalidNetwork
}
