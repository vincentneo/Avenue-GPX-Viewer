//
//  GPXTileServer.swift
//  OpenGpxTracker
//
//  Created by merlos on 25/01/15.
//
// Shared file: this file is also included in the OpenGpxTracker-Watch Extension target.

import Foundation

///
/// Configuration for supported tile servers.
///
/// Maps displayed in the application are sets of small square images caled tiles. There are different servers that
/// provide these tiles.
///
/// A tile server is defined by an internal id (for instance .openStreetMap), a name string for displaying
/// on the interface and a URL template.
///
enum GPXTileServer: Int, CaseIterable {
    
    /// Apple tile server
    case apple
    
    /// Open Street Map tile server
    case openStreetMap = 4
    //case AnotherMap
    
    /// CartoDB tile server
    case cartoDB
    
    /// OpenTopoMap tile server
    case openTopoMap
    
    /// CyclOSM tile server
    case cyclOSM
    
    ///String that describes the selected tile server.
    var name: String {
        switch self {
        case .apple: return "Apple Mapkit (no offline cache)"
        case .openStreetMap: return "Open Street Map"
        case .cartoDB: return "CARTO"
        case .openTopoMap: return "OpenTopoMap"
        case .cyclOSM: return "CyclOSM"
        //case .AnotherMap: return "My Map"
        }
    }
    
    /// URL template of current tile server (it is of the form http://{s}.map.tile.server/{z}/{x}/{y}.png
    var templateUrl: String {
        switch self {
        case .apple: return ""
        case .openStreetMap: return "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
       // case .cartoDB: return "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
        case .cartoDB: return "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png"
        case .openTopoMap: return "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
        case .cyclOSM: return "https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png"
        //case .AnotherMap: return "http://another.map.tile.server/{z}/{x}/{y}.png"
        }
    }
    
    /// URL template of current tile server (it is of the form http://{s}.map.tile.server/{z}/{x}/{y}.png
    var retinaUrl: String? {
        switch self {
        case .cartoDB: return "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png"
        default: return nil
        }
    }
    
    /// In the `templateUrl` the {s} means subdomain, typically the subdomains available are a,b and c
    /// Check the subdomains available for your server.
    ///
    /// Set an empty array (`[]`) in case you don't use `{s}` in your `templateUrl`.
    ///
    /// Subdomains is useful to distribute the tile request download among the diferent servers
    /// and displaying them faster as result.
    var subdomains: [String] {
        switch self {
        case .apple: return []
        case .openStreetMap: return ["a","b","c"]
        case .cartoDB: return ["a","b","c","d"]
        case .openTopoMap: return ["a","b","c"]
        case .cyclOSM: return ["a", "b", "c"]
        //case .AnotherMap: return ["a","b"]
        }
    }
    /// Maximum zoom level the tile server supports
    /// Tile servers provide files till a certain level of zoom that ranges from 0 to maximumZ.
    /// If map zooms more than the limit level, tiles won't be requested.
    ///
    ///  Typically the value is around 19,20 or 21.
    ///
    ///  Use negative to avoid setting a limit.
    ///
    /// - see https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Tile_servers
    ///
    var maximumZ: Int {
        switch self {
            case .apple: return -1
            case .openStreetMap: return 19
            case .cartoDB: return 25
            case .openTopoMap: return 17
            case .cyclOSM: return 19
            //case .AnotherMap: return 10
        }
    }
    ///
    /// Minimum zoom supported by the tile server
    ///
    /// This limits the tiles requested based on current zoom level.
    /// No tiles will be requested for zooms levels lower that this.
    ///
    /// Needs to be 0 or larger.
    ///
    var minimumZ: Int {
        switch self {
            case .apple: return 0
            case .openStreetMap: return 0
            case .cartoDB: return 0
            case .openTopoMap: return 0
            case .cyclOSM: return 0
            //case .AnotherMap: return ["a","b"]
        }
    }
    
    var attribution: String {
        switch self {
        case .apple: return ""
        case .openStreetMap: return "© OpenStreetMap contributors"
        case .cartoDB: return "© OpenStreetMap contributors, © CARTO"
        case .openTopoMap: return "© OpenStreetMap contributors, SRTM, © OpenTopoMap (CC-BY-SA)"
        case .cyclOSM: return " CyclOSM | Map data © OpenStreetMap contributors"
        }
    }
    
    /// Returns the number of tile servers currently defined
    static var count: Int { return GPXTileServer.cyclOSM.rawValue + 1 }
    
    static var allCases: [GPXTileServer] { return [.openStreetMap, .cartoDB,
                                                   .openTopoMap,
                                                   .cyclOSM]}
}
