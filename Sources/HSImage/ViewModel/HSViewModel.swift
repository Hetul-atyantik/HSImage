//
//  HSViewModel.swift
//  
//
//  Created by Hetul Soni on 25/08/23.
//

import Foundation

class HSImageViewModel: ObservableObject {
    public enum ImageStateValue {
        case loading
        case nameIntials(nameInitials: String)
        case localImage(path: String?)
        case webImage(url: URL)
        case failure
    }
    
    var imageURL: String?
    let nameInitials: String?
    let urlType: ResourceType
    
    @Published private(set) var currentImageState : ImageStateValue! = .loading
    @Published private(set) var forcedUpdate: Bool = false
    
    init(imageURL: String? = nil, nameInitials: String?, urlType: ResourceType) {
        self.imageURL = imageURL
        self.nameInitials = nameInitials
        self.urlType = urlType
    }
    
}

//MARK:- Other methods
extension HSImageViewModel {
    func setupState(isLocalImage: Bool = false) {
        switch urlType {
        case .youtube:
            prepareThumbnailURL(type: urlType)
            if let imgString = imageURL?.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: imgString) {
                currentImageState = .webImage(url: url)
            }
            else {
                setFailure()
            }
            forcedUpdate.toggle()
            objectWillChange.send()
        case .url:
            if let imgString = imageURL?.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let imgURL = URL(string: imgString) {
                if FileManager.default.fileExists(atPath: imgURL.path) {
//                    if imgURL.pathExtension.lowercased().contains("gif") {
//                        currentImageState = .animated(url: URL(fileURLWithPath: imgURL.path))
//                    }
//                    else {
                        currentImageState = .localImage(path: imgURL.path)
//                    }
                }
                else {
                    currentImageState = .webImage(url: imgURL)
                }
                forcedUpdate.toggle()
                objectWillChange.send()
            }
            else if let nameInitials = nameInitials {
                currentImageState = .nameIntials(nameInitials: nameInitials)
                forcedUpdate.toggle()
                objectWillChange.send()
            }
            else {
                setFailure()
            }
        case .image:
            currentImageState = .localImage(path: nil)
            forcedUpdate.toggle()
            objectWillChange.send()
        }
    }
    
    func setFailure() {
        currentImageState = .failure
        forcedUpdate.toggle()
        objectWillChange.send()
    }
    
}

extension HSImageViewModel {
    
    fileprivate func getVideoId(_ url: String, regex: String) throws -> String? {
        
        let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
        let range = NSRange(location: 0, length: url.count)
        if let matchRange = regex.firstMatch(in: url, options: .reportCompletion, range: range)?.range {
            let matchLength = (matchRange.lowerBound + matchRange.length) - 1
            if range.contains(matchRange.lowerBound) &&
                range.contains(matchLength) {
                let start = url.index(url.startIndex, offsetBy: matchRange.lowerBound)
                let end = url.index(url.startIndex, offsetBy: matchLength)
                return String(url[start...end])
            }
        }
        return nil
    }
    
    /// prepares thumbnail url
    public func prepareThumbnailURL(type: ResourceType) {
        switch type {
        case .youtube:
            let regex = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
            guard let url = imageURL?.removingPercentEncoding, let videoId = try? getVideoId(url, regex: regex) else {
                return
            }
            imageURL = "https://img.youtube.com/vi/\(videoId)/hqdefault.jpg"
        default:
            break
        }
    }
}
