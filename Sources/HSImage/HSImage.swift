import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

public struct HSImage: View {
    
    let imageObj : UIImage?
    let contentMode : ContentMode
    let isZoomAllowed: Bool
    
    let placeHolderImage : Image
    let failureImage : Image
    
    let size: CGSize
    let placeHolderOrFailurImageRatio: CGFloat
    
    let indicatorColor: Color
    @State var isLoading = true
    @StateObject var viewModel:
    HSImageViewModel
    
    public init(_ url: String? = nil, imageObj : UIImage? = nil, urlType: ResourceType = .url, contentMode : ContentMode = .fill, isZoomAllowed: Bool = false, nameInitials: String? = nil, placeHolderImage : Image, failureImage: Image, indicatorColor: Color = Color.gray, size: CGSize, placeHolderOrFailurImageRatio: CGFloat = 0.4) {
        
        self.imageObj = imageObj
        
        self.contentMode = contentMode
        self.isZoomAllowed = isZoomAllowed
        
        self.placeHolderImage = placeHolderImage
        self.failureImage = failureImage
        self.indicatorColor = indicatorColor
        
        self.size = size
        self.placeHolderOrFailurImageRatio = placeHolderOrFailurImageRatio
        
        _viewModel = StateObject(wrappedValue: HSImageViewModel(imageURL: url, nameInitials: nameInitials, urlType: urlType))
        
    }
    
    public var body: some View {
        if viewModel.forcedUpdate {
            makeBody()
        }
        else {
            makeBody()
        }
    }
    
    @ViewBuilder func makeBody() -> some View {
        switch viewModel.currentImageState {
            
        case .nameIntials(let nameInitials):
            makeInitialsView(nameInitials)
            
//        case .animated(let data):
//            makeLocalAnimatedImageView(data)
//                .manageZoom(isZoomAllowed: isZoomAllowed)
            
        case .localImage(let path):
            if let imagePath = path, let img = UIImage(contentsOfFile: imagePath) {
                makeLocalImageView(img)
            }
            else if let img = imageObj {
                makeLocalImageView(img)
            }
            else{
                makeFailureImage()
            }
            
        case .webImage(let url):
            makeRemoteImageView(url)
            
        case .failure:
            makeFailureImage()
            
        default:
            makePlaceHolderView()
                .onAppear {
                    DispatchQueue.main.async {
                        self.viewModel.setupState(isLocalImage: (self.imageObj != nil))
                    }
                }
        }
    }
}

extension HSImage {
    
    /// make Remote Image UI
    @ViewBuilder private func makeRemoteImageView(_ imageURL: URL)->some View {
        WebImage(url: imageURL)
            .onFailure(perform: { _ in
                DispatchQueue.main.async {
                    self.viewModel.setFailure()
                }
            })
            .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
            .placeholder {
                makePlaceHolderView()
            }
            .onProgress(perform: { received, expected in
                isLoading = received != expected
            })
            .indicator(
                Indicator(content: { isAnimating, progress in
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: indicatorColor))
                        .scaleEffect(1.5)
                        .padding(8)
                        .opacity(isLoading == true ? 0.85: 0)
                })
            ) // Activity Indicator
            .aspectRatio(contentMode: contentMode)
            .frame(width: size.width, height: size.height, alignment: .center)
            .clipped()
    }
    
    /// make Animated Image UI
//    @ViewBuilder private func makeLocalAnimatedImageView(_ url: URL)->some View {
//        GIFView(url: url)
//            .frame(width: size.width, height: size.height, alignment: .center)
//            .scaledToFill()
//            .clipped()
//    }
    
    /// make Loading UI
    @ViewBuilder private func makeLocalImageView(_ image: UIImage)->some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(width: size.width, height: size.height, alignment: .center)
            .clipped()
    }
    
    /// make Loading UI
    @ViewBuilder private func makePlaceHolderView()->some View {
        VStack{
            placeHolderImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width * placeHolderOrFailurImageRatio, height: size.height * placeHolderOrFailurImageRatio, alignment: .center)
        }
        .frame(width: size.width, height: size.height, alignment: .center)
        .clipped()
    }
    
    /// make Failure UI
    @ViewBuilder private func makeFailureImage()->some View {
        VStack{
            failureImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width * placeHolderOrFailurImageRatio, height: size.height * placeHolderOrFailurImageRatio, alignment: .center)
        }
        .frame(width: size.width, height: size.height, alignment: .center)
        .clipped()
    }
    
    /// Make initials UI
    @ViewBuilder private func makeInitialsView(_ value: String)->some View {
        VStack(alignment: .center) {
            Text(value)
                .padding(4)
                .scaledToFit()
                .minimumScaleFactor(0.01)
                .lineLimit(1)
        }
        .frame(width: size.width, height: size.height, alignment: .center)
    }
}
