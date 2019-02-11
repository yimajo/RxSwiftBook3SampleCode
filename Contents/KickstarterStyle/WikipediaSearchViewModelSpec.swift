//
//  WikipediaSearchViewModelSpec.swift
//  SergdortStyleTests
//
//  Created by Yoshinori Imajo on 2019/01/03.
//  Copyright © 2019 Yoshinori Imajo. All rights reserved.
//

import RxSwift
import RxTest
import Quick
import Nimble

@testable import Library
@testable import KickstarterStyle

class WikipediaSearchViewModelSpec: QuickSpec {
  let disposeBag = DisposeBag()

  override func spec() {
    describe("入力に対する出力") {
      context("フィルタ境界付近のデータが入力される") {
        // 1.
        let scheduler = TestScheduler(initialClock: 0, resolution: 0.1)
        // 条件の準備
        let inputTextObservable = [
          Recorded.next(1, "S"),   // 2.
          Recorded.next(2, "Swi"), // 3.
          Recorded.next(6, "Swif") // 4.
        ]

        let mockPage1 = try! JSONDecoder().decode(
          WikipediaPage.self,
          from: "{\"pageid\": 1, \"title\": \"スイフト\"}".data(using: .utf8)!
        )

        let mockPage2 = try! JSONDecoder().decode(
          WikipediaPage.self,
          from: "{\"pageid\": 2, \"title\": \"テイラー\"}".data(using: .utf8)!
        )

        let wikipediaAPI = MockWikipediaAPI(
          results: Observable.of([mockPage1, mockPage2])
        )

        it("境界を超えたタイミングでモック用データと同じ結果が出力される") {
          // 結果をbindするObserver
          let pagesObserver: TestableObserver<[WikipediaPage]>
          let resultDescriptionObserver: TestableObserver<String>

          do {
            let viewModel = WikipediaSearchViewModel(wikipediaAPI: wikipediaAPI,
                                                     scheduler: scheduler)

            let searchText = scheduler.createHotObservable(inputTextObservable)

            searchText.asObservable()
              .subscribe(onNext: {
                viewModel.inputs.searchTextChanged($0)
              })
              .disposed(by: self.disposeBag)

            pagesObserver = scheduler.createObserver([WikipediaPage].self)
            viewModel.outputs.wikipediaPages
              .bind(to: pagesObserver)
              .disposed(by: self.disposeBag)

            resultDescriptionObserver = scheduler.createObserver(String.self)
            viewModel.outputs.searchDescription
              .bind(to: resultDescriptionObserver)
              .disposed(by: self.disposeBag)

            scheduler.start()
          }

          expect(pagesObserver.events).to(equal([
            Recorded.next(5, [mockPage1, mockPage2]), // 5.
            Recorded.next(9, [mockPage1, mockPage2])  // 6.
          ]))

          expect(resultDescriptionObserver.events).to(equal([
            Recorded.next(5, "Swi 2件"),
            Recorded.next(9, "Swif 2件")
          ]))
        }
      }
    }
  }
}
