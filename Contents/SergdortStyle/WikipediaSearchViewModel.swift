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

class WikipediaSearchViewModel {
  private let disposeBag = DisposeBag()

  private let wikipediaAPI: WikipediaAPI
  private let scheduler: SchedulerType

  init(wikipediaAPI: WikipediaAPI,
       scheduler: SchedulerType = ConcurrentMainScheduler.instance) {
    self.wikipediaAPI = wikipediaAPI
    // 1.
    self.scheduler = scheduler
  }
}

extension WikipediaSearchViewModel: ViewModelType {
  // 2.
  struct Input {
    let searchText: Observable<String>
  }

  struct Output {
    let wikipediaPages: Observable<[WikipediaPage]>
    let searchDescription: Observable<String>
    let error: Observable<Error>
  }

  func transform(input: Input) -> Output {

    let filterdText = input.searchText
      .debounce(.milliseconds(300), scheduler: scheduler)
      .share(replay: 1)

    let sequence = filterdText
      .flatMapLatest { [unowned self] text -> Observable<Event<[WikipediaPage]>> in
        return self.wikipediaAPI
          .search(from: text)
          .materialize()
      }
      .share(replay: 1)

    let wikipediaPages = sequence.elements()

    // 3.
    let _searchDescription = PublishRelay<String>()

    // 4.
    wikipediaPages
      .withLatestFrom(filterdText) { (pages, word) -> String in
        return "\(word) \(pages.count)件"
      }
      .bind(to: _searchDescription)
      .disposed(by: disposeBag)

    return Output(wikipediaPages: wikipediaPages,
                  searchDescription: _searchDescription.asObservable(),
                  error: sequence.errors())
  }
}
