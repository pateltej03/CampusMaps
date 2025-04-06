//
//  Building.swift
//  CampusMaps
//
//  Created by Tej Patel on 07/10/24.
//
//

import Foundation
import MapKit

struct Building: Identifiable, Codable {
    let latitude: Double
    let longitude: Double
    let name: String
    let opp_bldg_code: Int
    let year_constructed: Int?
    let photo: String?

    var id = UUID()
    var isMapped: Bool = false
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, name, opp_bldg_code, year_constructed, photo, isMapped, isFavorite
    }
    
    var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        name = try container.decode(String.self, forKey: .name)
        opp_bldg_code = try container.decode(Int.self, forKey: .opp_bldg_code)
        year_constructed = try container.decodeIfPresent(Int.self, forKey: .year_constructed)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
        isMapped = try container.decodeIfPresent(Bool.self, forKey: .isMapped) ?? false
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(name, forKey: .name)
        try container.encode(opp_bldg_code, forKey: .opp_bldg_code)
        try container.encodeIfPresent(year_constructed, forKey: .year_constructed)
        try container.encodeIfPresent(photo, forKey: .photo)
        try container.encode(isMapped, forKey: .isMapped)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}

