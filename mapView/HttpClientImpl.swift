//
//  HttpClientImpl.swift
//
//  Created by Step App School on 2017/06/01.
//  Copyright © 2017年 Step App School. All rights reserved.
//

import Foundation

public class HttpClientImpl {
	
	private let session: URLSession
	let semaphore = DispatchSemaphore(value: 0)
	
	public init(config: URLSessionConfiguration? = nil) {
		self.session = config.map { URLSession(configuration: $0) } ?? URLSession.shared
	}
	
	public func execute(request: NSURLRequest) -> (Data?, URLResponse?,Error?) {
		var d: Data? = nil
		var r: URLResponse? = nil
		var e: Error? = nil
		
		session
			.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
				d = data
				r = response
				e = error
				self.semaphore.signal()
			}
			.resume()
		self.semaphore.wait()
		return (d, r, e)
	}
	
}
