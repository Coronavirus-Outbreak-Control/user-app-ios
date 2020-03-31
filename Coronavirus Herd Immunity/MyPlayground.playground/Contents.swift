import UIKit

var str = "Hello, playground"

class IBeaconDto: Codable, CustomDebugStringConvertible {
    public var identifier : Int64
    public var rssi : Int64
    public var interval : Double
    public var distance : Int
    public var lat : Double
    public var lon : Double
}
