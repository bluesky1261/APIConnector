//
//  TopicModel.swift
//  
//
//  Created by Joonghoo Im on 2022/05/15.
//

import Foundation

struct TopicModel {
}

// MARK: - TopicModel Request
extension TopicModel {
    struct Request: Codable {
        let page: Int
    }
}

// MARK: - TopicModel Response
extension TopicModel {
    struct Response: Codable {
        let id: String
        let slug: String
        let title: String
        let description: String?
        let publishedAt: String
        let updatedAt: String?
        let startsAt: String
        let endsAt: String?
        let featured: Bool
        let totalPhotos: UInt32
        
        private enum CodingKeys: String, CodingKey {
            case id
            case slug
            case title
            case description
            case publishedAt = "published_at"
            case updatedAt = "updated_at"
            case startsAt = "starts_at"
            case endsAt = "ends_at"
            case featured
            case totalPhotos = "total_photos"
        }
    }
}
