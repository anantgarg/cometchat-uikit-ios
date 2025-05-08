//
//
//

import SwiftUI
import QuickLook
import CometChatSDK

public struct CometChatImageBubbleSwiftUI: View {
    private var style: ImageBubbleStyle
    private var imageURL: String?
    private var localFileURL: String?
    private var thumbnailURL: String?
    private var onClick: (() -> Void)?
    
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    @State private var previewItemURL: URL?
    @State private var showQuickLook: Bool = false
    @State private var retryCount: Int = 0
    @State private var isPhotoNeedToDownload: Bool = false
    
    public init(style: ImageBubbleStyle = ImageBubbleStyle()) {
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(style.imageBorderCornerRadius.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: style.imageBorderCornerRadius.cornerRadius)
                                .stroke(Color(style.imageBorderColor), lineWidth: style.imageBorderWidth)
                        )
                } else {
                    RoundedRectangle(cornerRadius: style.imageBorderCornerRadius.cornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: style.imageBorderCornerRadius.cornerRadius)
                                .stroke(Color(style.imageBorderColor), lineWidth: style.imageBorderWidth)
                        )
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .onTapGesture {
                onImageClick()
            }
            .quickLookPreview($previewItemURL, in: [previewItemURL].compactMap { $0 })
        }
        .padding(.horizontal, CometChatSpacing.Padding.p1)
        .padding(.top, CometChatSpacing.Padding.p1)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        isLoading = true
        
        if let localFileURL = localFileURL, let url = URL(string: localFileURL), url.checkFileExist() {
            self.imageURL = localFileURL
            do {
                let imageData = try Data(contentsOf: url)
                if let loadedImage = UIImage(data: imageData) {
                    self.image = loadedImage
                    self.previewItemURL = url
                    self.isLoading = false
                }
            } catch {
                self.imageURL = imageURL
                setPreviewImage(url: imageURL ?? "")
            }
        } else if let thumbnailURL = thumbnailURL {
            self.isPhotoNeedToDownload = true
            setPreviewImage(url: thumbnailURL)
        } else if let imageURL = imageURL {
            setPreviewImage(url: imageURL)
        } else {
            isLoading = false
        }
    }
    
    private func setPreviewImage(url: String) {
        previewMediaMessage(url: url) { success, fileLocation in
            guard let fileLocation = fileLocation else { return }
            
            DispatchQueue.main.async {
                do {
                    let imageData = try Data(contentsOf: fileLocation)
                    if let loadedImage = UIImage(data: imageData) {
                        self.image = loadedImage
                        self.previewItemURL = fileLocation
                    }
                } catch {
                }
                self.isLoading = false
            }
        }
    }
    
    private func previewMediaMessage(url: String, completion: @escaping (_ success: Bool, _ fileLocation: URL?) -> Void) {
        guard let itemUrl = URL(string: url) else {
            completion(false, nil)
            return
        }
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(itemUrl.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else if itemUrl.checkFileExist() {
            completion(true, destinationUrl)
        } else {
            downloadImage(url: itemUrl, completion: completion)
        }
    }
    
    private func downloadImage(url: URL, completion: @escaping (_ success: Bool, _ fileLocation: URL?) -> Void) {
        if retryCount >= 5 {
            completion(false, nil)
            return
        }
        
        retryCount += 1
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let tempLocation = location, error == nil else {
                DispatchQueue.main.async {
                    self.downloadImage(url: url, completion: completion)
                }
                return
            }
            
            do {
                try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                completion(true, destinationUrl)
            } catch {
                completion(false, nil)
            }
        }
        
        downloadTask.resume()
    }
    
    private func onImageClick() {
        if let onClick = onClick {
            onClick()
        } else if isPhotoNeedToDownload, let imageURL = imageURL {
            isLoading = true
            previewMediaMessage(url: imageURL) { success, fileLocation in
                guard let fileLocation = fileLocation else { return }
                
                DispatchQueue.main.async {
                    do {
                        let imageData = try Data(contentsOf: fileLocation)
                        if let loadedImage = UIImage(data: imageData) {
                            self.image = loadedImage
                            self.previewItemURL = fileLocation
                        }
                    } catch {
                    }
                    
                    self.isLoading = false
                    self.showQuickLook = true
                }
            }
        } else {
            showQuickLook = true
        }
    }
    
    public func set(image: UIImage) -> CometChatImageBubbleSwiftUI {
        var view = self
        view.image = image
        return view
    }
    
    public func set(imageUrl: String, localFileURL: String? = nil, thumbnailURL: String? = nil) -> CometChatImageBubbleSwiftUI {
        var view = self
        view.imageURL = imageUrl
        view.localFileURL = localFileURL
        view.thumbnailURL = thumbnailURL
        return view
    }
    
    public func setOnClick(onClick: @escaping () -> Void) -> CometChatImageBubbleSwiftUI {
        var view = self
        view.onClick = onClick
        return view
    }
}

extension CometChatImageBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatImageBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatImageBubbleSwiftUI()
                .set(imageUrl: "https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg")
                .frame(width: 200, height: 200)
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatImageBubbleSwiftUI()
                .set(imageUrl: "https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg")
                .frame(width: 200, height: 200)
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
