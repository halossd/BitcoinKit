//
//  BitcoinComTransactionBroadcaster.swift
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

public final class BitcoinComTransactionBroadcaster: TransactionBroadcaster {
    private let endpoint: ApiEndPoint.ChainSo
    public init(network: Network) {
        self.endpoint = ApiEndPoint.ChainSo(network: network)
    }

    public func post(_ rawtx: String, completion: ((_ txid: String?) -> Void)?) {
        let url = endpoint.postRawtxURL() //https://testnet-api.smartbit.com.au/v1/blockchain/pushtx
        var request = URLRequest(url: url)
        print("url \(url)\n tx \(rawtx)")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["hex": rawtx])
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                print("response is nil.")
                completion?(nil)
                return
            }
            guard let response = String(bytes: data, encoding: .utf8) else {
                print("broadcast response cannot be decoded.")
                return
            }

            completion?(response)
        }
        task.resume()
    }
}
