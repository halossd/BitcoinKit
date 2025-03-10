//
//  ViewController.swift
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

import UIKit
import BitcoinKit

class ViewController: UIViewController {
    @IBOutlet private weak var qrCodeImageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var destinationAddressTextField: UITextField!
    
    private var wallet: Wallet?  = Wallet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWalletIfNeeded()
        self.updateLabels()
    
//        wallet?.getBalance(completion: { (result) in
//            switch result {
//            case .success(let a) :
//                print(a)
//            case .failure(let error):
//                print(error)
//            }
//        })
//
//        wallet?.getUtxos(completion: { (result) in
//            switch result {
//            case .success(let a):
//                let b = a?.txs![0]
//                print(b?.asUtxo())
//            case .failure(let error):
//                print(error)
//            }
//
//        })
        
//        let mnemonic = try! Mnemonic.generate()
//        let seed = Mnemonic.seed(mnemonic: mnemonic)
//        let keychain = HDKeychain(seed: seed, network: .mainnet)
//        let privateKey = try! keychain.derivedKey(path: "m/44'/0'/0'/0/0")
//        let publicKey = try! keychain.derivedKey(path: "M/44'/0'/0'/0/0")
//        print("prvKey pub: \(privateKey.extendedPublicKey().publicKey().description)")
//        print("publickey: \(publicKey)")
    }
    
    func createWalletIfNeeded() {
//        if wallet == nil {
            wallet = Wallet(privateKey: try! PrivateKey(wif: "cRbHoMJ97XmnEMasBmpQoHiBL7jisqX2M2KdXFguYtrYEtrtjvpT"))
            wallet?.save()
//        }
    }
    
    func updateLabels() {
        qrCodeImageView.image = wallet?.address.qrImage()
        addressLabel.text = wallet?.address.cashaddr
        if let balance = wallet?.balance() {
            balanceLabel.text = "Balance : \(balance) satoshi"
        }
    }
    
    func updateBalance() {
//        wallet?.reloadBalance(completion: { [weak self] (utxos) in
//            DispatchQueue.main.async { self?.updateLabels() }
//        })
        Wallet.getBalance(network: .testnet, address: try! AddressFactory.create("mp9ko3jhiHo9C7QRASQVFSQV7DPXyWq7bW")) { (result) in
            switch result {
            case .success(let a):
                print(a)
            case .failure(let error):
                print(error)
            }
        }
//        wallet?.getUtxos(completion: { (result) in
//            switch result {
//            case .success(let a):
//                print(a)
//            case .failure(let error):
//                print(error)
//            }
//        })
    }

    @IBAction func didTapReloadBalanceButton(_ sender: UIButton) {
        updateBalance()
    }
    
    @IBAction func didTapSendButton(_ sender: UIButton) {
        guard let addressString = destinationAddressTextField.text else {
            return
        }
        
        do {
            let address: Address = try AddressFactory.create("mp9ko3jhiHo9C7QRASQVFSQV7DPXyWq7bW")
            try wallet?.send(to: address, amount: 10000, completion: { [weak self] (response) in
                print(response ?? "")
            })
        } catch {
            print(error)
        }

    }
}

