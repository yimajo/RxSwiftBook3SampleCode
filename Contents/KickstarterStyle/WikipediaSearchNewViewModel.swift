//
//  WikipediaSearchNewViewModel.swift
//  KickstarterStyle
//
//  Created by Yoshinori Imajo on 2019/01/24.
//  Copyright © 2019 Yoshinori Imajo. All rights reserved.
//

import RxSwift
import RxCocoa
import Library

func wikipediaSearchViewModel(
  searchText: Observable<String>,
  dependency: ( // 1.
    disposeBag: DisposeBag,
    wikipediaAPI: WikipediaAPI,
    scheduler: SchedulerType
  )
) -> ( // 2.
  wikipediaPages: Observable<[WikipediaPage]>,
  searchDescription: Observable<String>,
  error: Observable<Error>
) {
    let filteredText = searchText
      .debounce(0.3, scheduler: dependency.scheduler)
      .share(replay: 1)

    let sequence = filteredText
      .flatMapLatest { text -> Observable<Event<[WikipediaPage]>> in
        guard !text.isEmpty else {
          return Observable.just([]).materialize()
        }

        return dependency.wikipediaAPI
          .search(from: text)
          .materialize()
      }
      .share(replay: 1)

    let wikipediaPages = sequence.elements()

    let _searchResultText = PublishRelay<String>()

    wikipediaPages
      .withLatestFrom(filteredText) { (pages, word) -> String in
        return "\(word) \(pages.count)件"
      }
      .bind(to: _searchResultText)
      .disposed(by: dependency.disposeBag)

    return (wikipediaPages: wikipediaPages,
            searchDescription: _searchResultText.asObservable(),
            error: sequence.errors())
}
