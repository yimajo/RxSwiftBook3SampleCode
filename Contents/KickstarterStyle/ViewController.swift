//
//  ViewController.swift
//  SergdortStyle
//
//  Created by Yoshinori Imajo on 2019/01/01.
//  Copyright © 2019 Yoshinori Imajo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Library

class ViewController: UIViewController {

  @IBOutlet private weak var searchBar: UISearchBar!
  @IBOutlet private weak var tableView: UITableView!
  private let disposeBag = DisposeBag()

  // 1.
  let viewModel = WikipediaSearchViewModel(
    wikipediaAPI: WikipediaDefaultAPI(URLSession: .shared)
  )

  override func viewDidLoad() {
    super.viewDidLoad()

    searchBar.rx.text.orEmpty
      .subscribe(onNext: { [unowned self] in
        self.viewModel.inputs.searchTextChanged($0)
      })
      .disposed(by: disposeBag)

    viewModel.outputs.searchDescription
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)

    // 3.
    viewModel.outputs.wikipediaPages
      .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { index, result, cell in
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.url.absoluteString
      }
      .disposed(by: disposeBag)

    // 4.
    viewModel.outputs.error
      .subscribe(onNext: { error in
        if let error = error as? URLError,
          error.code == URLError.notConnectedToInternet {
          // ここでネット接続していない旨を表示する
          print(error)
        }
      })
      .disposed(by: disposeBag)
  }
}
