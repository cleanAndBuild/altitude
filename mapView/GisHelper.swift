//
//  GisHelper.swift
//
//  Created by Step App School on 2017/06/01.
//  Copyright © 2017年 Step App School. All rights reserved.
//

import Foundation
import CoreLocation

class GisHelper {
	static let INVALID_ALT:Double = -9999
	
	
	//距離を計算する mで返す
	static func CalcDistance(from:CLLocationCoordinate2D,to:CLLocationCoordinate2D)->Double
	{
		return GisHelper.CalcDistance(fromLat:from.latitude,fromLon:from.longitude,toLat:to.latitude,toLon:to.longitude)
	}
	
	//距離を計算する mで返す
	static func CalcDistance(fromLat:Double,fromLon:Double,toLat:Double, toLon:Double)->Double {
		
		var distance:Double = 0.0
		
		let fromLat:Double = fromLat * Double.pi / 180
		let fromLon:Double = fromLon * Double.pi / 180
		let toLat:Double = toLat * Double.pi / 180
		let toLon:Double = toLon * Double.pi / 180
		
		let A:Double = 6378140.0
		let B:Double = 6356755.0
		let F:Double = (A - B) / A
		
		let P1:Double = atan((B / A) * tan(fromLat))
		let P2:Double = atan((B / A) * tan(toLat))
		
		
		let X:Double = acos( sin(P1) * sin(P2) + cos(P1) * cos(P2) * cos(fromLon - toLon))
		let L:Double = ( F / 8) * ((sin(X) - X) * pow((sin(P1) + sin(P2)),2) / pow(cos(X/2),2) - (sin(X) - X) * pow(sin(P1) - sin(P2),2) / pow(sin(X),2))
		
		distance = A * (X + L)
		if(distance.isNaN) {
			distance = 0
		}
		return distance
	}


	
	//高度を取得する
	static func getAltitudeCoordinate(_ coordinate:CLLocationCoordinate2D)->Double {
		var isInJapan:Bool = true;
		if(coordinate.latitude < 19.353022 || coordinate.longitude < 122.330701 || coordinate.latitude > 45.591853 || coordinate.longitude > 154.374464) {
			isInJapan = false
		}
	
		var ret:Double = INVALID_ALT
		if(isInJapan) {
			//http://cyberjapandata2.gsi.go.jp/general/dem/scripts/getelevation.php?lon=140.08531&lat=36.103543&outtype=JSON
			let urlString:String = String(format:"https://cyberjapandata2.gsi.go.jp/general/dem/scripts/getelevation.php?lon=%f&lat=%f&outtype=JSON",coordinate.longitude,coordinate.latitude);

			do {
				let configuration = URLSessionConfiguration.default
				//configuration.timeoutIntervalForRequest = 3000
				let req = NSMutableURLRequest(url:NSURL(string:urlString)! as URL)
				
				let client:HttpClientImpl = HttpClientImpl.init(config: configuration)
				let result = client.execute(request: req)
				
				if(result.0 == nil) {
					ret = INVALID_ALT
				}
				else {
					let data:Data = result.0!
					//				let response:URLResponse = result.1!
					
					
					let json = try JSONSerialization.jsonObject(with: data) as! [String: AnyObject]
					let retString:NSString = json["hsrc"] as! NSString
					if(!retString.isEqual(to: "-----")) {
						ret = Double(json["elevation"] as! NSNumber)
					}
				}
			} catch {
				ret = INVALID_ALT
			// エラー
			}
		}

		//海外の場合
		if(!isInJapan || ret == INVALID_ALT) {
			//http://maps.googleapis.com/maps/api/elevation/json?locations=39.7391536,-104.9847034&sensor=true_or_false
			let urlString:String = String(format:"https://maps.googleapis.com/maps/api/elevation/json?locations=%f,%f&sensor=true_or_false",coordinate.latitude,coordinate.longitude);
			//{"results" : ["elevation" : 1608.637939453125,"location" : {"lat" : 39.7391536,"lng" : -104.9847034},"resolution" : 4.771975994110107}],"status" : "OK"}

			do {
				let configuration = URLSessionConfiguration.default
				configuration.timeoutIntervalForRequest = 3000
				let req = NSMutableURLRequest(url:NSURL(string:urlString)! as URL)
				
				let client:HttpClientImpl = HttpClientImpl.init(config: configuration)
				let result = client.execute(request: req)
				
				if(result.0 == nil) {
					ret = INVALID_ALT
				}
				else {
					let data:Data = result.0!
					//				let response:URLResponse = result.1!
					
					
					let json = try JSONSerialization.jsonObject(with: data) as! [String: AnyObject]
					let status:NSString = json["status"] as! NSString
					if(status.isEqual(to: "OK")) {
						let results = (json["results"]! as! NSArray).mutableCopy() as! NSMutableArray
						if(results.count > 0) {
							let ele = results.object(at: 0) as! [String: AnyObject]
							ret = Double(ele["elevation"] as! NSNumber)
						}
					}
				}
			} catch {
				return INVALID_ALT
				// エラー
			}
		}
		return ret
	}



}
