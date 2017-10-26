//
//  ViewController.swift
//  mapView
//
//  Created by Step App School on 2017/06/30.
//  Copyright © 2017年 Step App School. All rights reserved.
//

import UIKit
import MapKit
import Social

class ViewController: UIViewController,MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!//MapViewのアウトレット
    
    @IBOutlet var labelAltitude: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //UserDefaultsを生成
        let ud = UserDefaults.standard
        
        //経緯度を読み込む
		var lat = ud.double(forKey: "LAT")
		var lon = ud.double(forKey: "LON")

		if(lat <= 1.0 && lat >= -1.0) {lat = 35.0}
		if(lon <= 1.0 && lon >= -1.0) {lon = 139.0}

        //CLLocationCoordinate2Dに変換
        let coordinte = CLLocationCoordinate2DMake(lat,lon)
        
        //表示範囲を読み込む
        let latDelta = ud.double(forKey: "LAT_DELTA")
        let lonDelta = ud.double(forKey: "LON_DELTA")
		
        //MKCoordinateSpanに変換
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        
        //表示範囲と経緯度を地図に設定する
        mapView.region.span = span
        mapView.setCenter(coordinte, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //スクロールのデリゲートファンクション
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        //UserDefaultsを生成
        let ud = UserDefaults.standard
        
        //経緯度を保存する　LAT(LATITUDE):緯度 LON(LONGITUDE):経度
        ud.set(mapView.centerCoordinate.latitude, forKey: "LAT")
        ud.set(mapView.centerCoordinate.longitude, forKey: "LON")
        
        //表示範囲を保存する
        ud.set(mapView.region.span.latitudeDelta, forKey: "LAT_DELTA")
        ud.set(mapView.region.span.longitudeDelta, forKey: "LON_DELTA")

        ud.synchronize()
        
        //経緯度を渡して標高を取得する
        let altitude:Double = GisHelper.getAltitudeCoordinate(mapView.centerCoordinate)
        
        if(altitude != GisHelper.INVALID_ALT){
            labelAltitude.text = String(format: "%.1fm", altitude)
        }
        else {
            labelAltitude.text = ""
        }
    }
    
    //Facebookボタンを押した場合
    @IBAction func tapFacebook(_ sender: Any) {
        let facebookPostView = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
        facebookPostView.setInitialText("ここの標高は" + labelAltitude.text! + "です")
        self.present(facebookPostView, animated: true, completion: nil)
    }
    
    //Twitterボタンを押した場合
    @IBAction func tapTwitter(_ sender: Any) {
        let twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
        twitterPostView.setInitialText("ここの標高は" + labelAltitude.text! + "です")
        self.present(twitterPostView, animated: true, completion: nil)
    }
    


}

