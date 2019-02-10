//
//  WikipediaPage.swift
//  Library
//
//  Created by Yoshinori Imajo on 2019/02/10.
//  Copyright © 2019 Yoshinori Imajo. All rights reserved.
//

import Foundation

public struct WikipediaSearchResponse: Decodable {
    public let query: Query

    public struct Query: Decodable {
        public let search: [Library.WikipediaPage]
    }
}

public struct WikipediaPage {
    public let id: String
    public let title: String
    public let url: URL
}

extension WikipediaPage: Equatable {
    public static func == (lhs: WikipediaPage, rhs: WikipediaPage) -> Bool {
        return lhs.id == rhs.id
    }
}

extension WikipediaPage: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "pageid"
        case title
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = String(try container.decode(Int.self, forKey: .id))

        self.title = try container.decode(String.self, forKey: .title)
        // 2.
        self.url =  URL(string: "https://ja.wikipedia.org/w/index.php?curid=\(id)")!
    }
}
