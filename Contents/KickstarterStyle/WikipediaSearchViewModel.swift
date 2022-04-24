//
//  WikipediaSearchViewModel.swift
//  SergdortStyle
//
//  Created by Yoshinori Imajo on 2019/01/01.
//  Copyright © 2019 Yoshinori Imajo. All rights reserved.
//

import RxSwift
import RxCocoa
import Library

// 1.
protocol WikipediaSearchViewModelInputs {
  func searchTextChanged(_ searchText: String)
}

protocol WikipediaSearchViewModelOutputs {
  var searchDescription: Observable<String> { get }
  // 内部ではSubjectだが書き込まれないようにObservableにしている
  var wikipediaPages: Observable<[WikipediaPage]> { get }
  var error: Observable<Error> { get }
}

protocol WikipediaSearchViewModelType {
  var inputs: WikipediaSearchViewModelInputs { get }
  var outputs: WikipediaSearchViewModelOutputs { get }
}

class WikipediaSearchViewModel: WikipediaSearchViewModelOutputs {
  private let disposeBag = DisposeBag()
  // 2.
  private let wikipediaAPI: WikipediaAPI
  private let scheduler: SchedulerType

  // 3.
  let searchDescription: Observable<String>
  let wikipediaPages: Observable<[WikipediaPage]>
  let error: Observable<Error>

  private let searchTextChangedProperty = BehaviorRelay<String>(value: "")

  init(wikipediaAPI: WikipediaAPI,
       scheduler: SchedulerType = ConcurrentMainScheduler.instance) {
    self.wikipediaAPI = wikipediaAPI
    self.scheduler = scheduler

    // 4.
    // BehaviorReplayにすると初期値を出力する。
    // 外部インターフェースはObservableなので初期値を持っているかどうか判断できないのでないほうがいい。
    let _wikipediaPages = PublishRelay<[WikipediaPage]>()
    self.wikipediaPages = _wikipediaPages.asObservable()

    // 最新の値をそのときに通知するだけで充分
    let _error = PublishRelay<Error>()
    self.error = _error.asObservable()

    let filterdText = searchTextChangedProperty
      .debounce(.milliseconds(300), scheduler: scheduler)
      .share(replay: 1)

    let _searchResultText = PublishRelay<String>()
    searchDescription = _searchResultText.asObservable()

    let sequence = filterdText
      .flatMapLatest { [unowned self] text -> Observable<Event<[WikipediaPage]>> in
        return self.wikipediaAPI
          .search(from: text)
          .materialize()
      }
      .share(replay: 1)

    wikipediaPages
      .withLatestFrom(filterdText) { (pages, word) -> String in
        return "\(word) \(pages.count)件"
      }
      .bind(to: _searchResultText)
      .disposed(by: disposeBag)

    // 5.
    sequence
      .elements()
      .bind(to: _wikipediaPages)
      .disposed(by: disposeBag)

    sequence
      .errors()
      .bind(to: _error)
      .disposed(by: disposeBag)
  }
}

extension WikipediaSearchViewModel: WikipediaSearchViewModelInputs {
  func searchTextChanged(_ searchText: String) {
    searchTextChangedProperty.accept(searchText)
  }
}

// 6.
extension WikipediaSearchViewModel: WikipediaSearchViewModelType {
  var inputs: WikipediaSearchViewModelInputs { return self }
  var outputs: WikipediaSearchViewModelOutputs { return self }
}
