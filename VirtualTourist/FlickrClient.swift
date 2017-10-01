//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/22/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class FlickrClient {
    
    private func getImagesFromFlickrBySearch(_ methodParameters: [String: AnyObject], completionHandlerForRequest: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: urlFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            
            let sessionData = self.sessionHandler(data, response, error, "getImagesFromFlickrBySearch")
            
            guard let data = sessionData.data else {
                completionHandlerForRequest(nil, sessionData.error)
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForRequest)
            
        }
        
        task.resume()
        return task
    }
    
    func getAndStoreImages(_ pin: Pin, pagenumber: Int = 1, _ completion: @escaping (_ error: Error?) -> Void) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        let coordinates = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let methodParameters = [
            Constants.FlickrParameterKeys.BoundingBox : bboxString(coordinates),
            Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback : Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage : Constants.FlickrParameterValues.PerPage,
            Constants.FlickrParameterKeys.Tags : Constants.FlickrParameterValues.Tags,
            Constants.FlickrParameterKeys.TagMode : Constants.FlickrParameterValues.TagMode,
            Constants.FlickrParameterKeys.Page : pagenumber
            ] as [String: AnyObject]
        _ = getImagesFromFlickrBySearch(methodParameters) { (data, error) in
            guard (error == nil) else {
                completion(error)
                return
            }
            guard let photosDictionary = data as? [String:AnyObject] else {
                return
            }
            guard let photos = photosDictionary["photos"] as? [String:AnyObject] else {
                return
            }
            guard let pages = photos["pages"] as? Int else {
                return
            }
            pin.pages = Int32(pages)
            guard let photoArray = photos["photo"] as? [[String:AnyObject]] else{
                return
            }
            
            for photo in photoArray {
                guard let photoUrlString = photo["url_m"] as? String else {
                    return
                }
                let placeholder = UIImagePNGRepresentation(UIImage(named: "default-placeholder")!)! as NSData
                let photo = Photo(data: placeholder, url: photoUrlString, context: stack.context)
                stack.save()
                photo.pin = pin
                self.downloadImage(photo, { (error) in
                    completion(error)
                })
            }
        }
    }
    
    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            let sessionData = self.sessionHandler(data, response, error, "getDataFromUrl")
            guard let data = sessionData.data else {
                completion(nil, nil, sessionData.error)
                return
            }
            completion(data, response, error)
            }.resume()
    }
    
    public func downloadImage(_ photo: Photo, _ completion: @escaping (_ error: Error?) -> Void) {
        guard let photoUrlString = photo.url, let photoUrl = URL(string: photoUrlString) else {
            return
        }
        getDataFromUrl(url: photoUrl) { (data, response, error)  in
            guard (error == nil) else {
                completion(error)
                return
            }
            guard let photoData = data as NSData? else {
                return
            }
            photo.data = photoData
        }
    }
    
    
    /// Function to create a URL from parameters
    ///
    /// - Parameter parameters: Parameters for the request
    /// - Returns: The URL created from the received parameters
    private func urlFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    /// Function to parse the data received from the requests and return the error given
    ///
    /// - Parameter data: Data received from the request
    /// - Returns: A string containing the server error
    private func parseDataStatus(_ data: Data) -> String {
        
        var parsedResult: [String:AnyObject]! = nil
        do{
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        }catch{
            return ""
        }
        return parsedResult["error"] as! String
    }
    
    /**
     Function to handle the response from the requests
     
     - parameter data: Data received from the request
     - parameter response: Server response
     - parameter error: The error of the call
     - parameter domain: Domain in which the function was called (used in the cases an error has to be created)
     - returns: A tuple containg the data already parsed and the error returned from the parsing (if any)
     
     */
    private func sessionHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ domain: String) -> (error: Error?, data: Data?) {
        
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            return (createError("There was an error with your request: \(error?.localizedDescription ?? "")", domain), nil)
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            let dataStatus = parseDataStatus(data!)
            return (createError("There was an error with your request: \(dataStatus)", domain), nil)
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            return (createError("No data was returned by the request!", domain), nil)
        }
        
        return (nil, data)
    }
    
    /**
     Function to create an error from a given String
     
     - parameter error: String containing the localizedDescription for the error
     - parameter domain: Domain in which the function was called
     - returns: The Error created from the received parameters
     
     */
    private func createError(_ error: String, _ domain: String) -> Error {
        let userInfo = [NSLocalizedDescriptionKey : error]
        return NSError(domain: domain, code: 1, userInfo: userInfo)
    }
    
    /// Given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    private func bboxString(_ coordinates: CLLocationCoordinate2D?) -> String {
        if let userLatitude = coordinates?.latitude, let userLongitude = coordinates?.longitude {
            let minLat = max(userLatitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maxLat = min(userLatitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            let minLong = max(userLongitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let maxLong = min(userLongitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
        } else {
            return "0,0,0,0"
        }
    }
    
    /**
     Function used to show a message given an error
     
     - parameter error: Error to be displayed
     - parameter sender: ViewController to display the error
     
     */
    func showErrorMessage(_ error: Error, _ sender: UIViewController){
        performUIUpdatesOnMain {
            let controller = UIAlertController(title: "Oops...", message: error.localizedDescription, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            sender.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
}


