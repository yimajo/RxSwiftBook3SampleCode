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
  private let viewModel = WikipediaSearchViewModel(
    wikipediaAPI: WikipediaDefaultAPI(URLSession: .shared)
  )

  override func viewDidLoad() {
    super.viewDidLoad()

    let input = WikipediaSearchViewModel.Input(
      searchText: searchBar.rx.text.orEmpty.asObservable()
    )

    // 2.
    let output = viewModel.transform(input: input)

    output.searchDescription
      .bind(to: navigationItem.rx.title)
      .disposed(by: disposeBag)

    // 3.
    output.wikipediaPages
      .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { index, result, cell in
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.url.absoluteString
      }
      .disposed(by: disposeBag)

    // 4.
    output.error
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
