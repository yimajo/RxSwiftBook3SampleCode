//
//  MockWikipediaAPI.swift
//  Library
//
//  Created by Yoshinori Imajo on 2019/02/10.
//  Copyright © 2019 Yoshinori Imajo. All rights reserved.
//

import RxSwift

struct MockWikipediaAPI {
    private let results: Observable<[WikipediaPage]>
    // 1.
    init(results: Observable<[WikipediaPage]>) {
        self.results = results
    }
}

// 2.
extension MockWikipediaAPI: WikipediaAPI {
    func search(from word: String) -> Observable<[WikipediaPage]> {
        return results
    }
}
