//
//  WikipediaSearchNewViewModelSpec.swift
//  KickstarterStyleTests
//
//  Created by Yoshinori Imajo on 2019/01/24.
//  Copyright © 2019 Yoshinori Imajo. All rights reserved.
//

import RxSwift
import RxTest
import Quick
import Nimble
import Foundation

@testable import Library
@testable import KickstarterStyle

class WikipediaSearchNewViewModelSpec: QuickSpec {

  let disposeBag = DisposeBag()

  override func spec() {
    describe("入力に対する出力") {
      context("フィルタ境界付近のデータが入力される") {
        let scheduler = TestScheduler(initialClock: 0, resolution: 0.1)

        // 条件の準備
        let inputTextObservable = [
          Recorded.next(1, "S"),
          Recorded.next(2, "Swi"),
          Recorded.next(6, "Swif")
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

          let pagesObserver: TestableObserver<[WikipediaPage]>
          let resultDescriptionObserver: TestableObserver<String>

          do {
            let searchText = scheduler.createHotObservable(inputTextObservable)

            let outputs = wikipediaSearchViewModel(
              searchText: searchText.asObservable(),
              dependency: (
                disposeBag: self.disposeBag,
                wikipediaAPI: wikipediaAPI,
                scheduler: scheduler
              )
            )

            pagesObserver = scheduler.createObserver([WikipediaPage].self)
            outputs.wikipediaPages
              .bind(to: pagesObserver)
              .disposed(by: self.disposeBag)

            resultDescriptionObserver = scheduler.createObserver(String.self)
            outputs.searchDescription
              .bind(to: resultDescriptionObserver)
              .disposed(by: self.disposeBag)

            scheduler.start()
          }

          expect(pagesObserver.events).to(equal([
            Recorded.next(5, [mockPage1, mockPage2]),
            Recorded.next(9, [mockPage1, mockPage2])
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
