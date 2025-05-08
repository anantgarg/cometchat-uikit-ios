//
//
//

import SwiftUI
import AVKit
import CometChatSDK

public struct CometChatVideoBubbleSwiftUI: View {
    private var style: VideoBubbleStyle
    private var thumbnailImageUrl: String?
    private var videoURL: String?
    @State private var thumbnailImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var thumbnailRetryCount: Int = 0
    @State private var showVideoPlayer: Bool = false
    
    public init(style: VideoBubbleStyle = VideoBubbleStyle()) {
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            ZStack {
                if let thumbnailImage = thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 232, height: 140)
                        .cornerRadius(style.videoCornerRadius.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: style.videoCornerRadius.cornerRadius)
                                .stroke(Color(style.videoBorderColor), lineWidth: style.videoBorderWidth)
                        )
                } else {
                    Image(uiImage: defaultThumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 232, height: 140)
                        .cornerRadius(style.videoCornerRadius.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: style.videoCornerRadius.cornerRadius)
                                .stroke(Color(style.videoBorderColor), lineWidth: style.videoBorderWidth)
                        )
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
                
                Circle()
                    .fill(Color(style.playButtonBackgroundColor))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(style.playButtonTint))
                    )
            }
            .frame(width: 232, height: 140)
            .onTapGesture {
                playVideo()
            }
            .fullScreenCover(isPresented: $showVideoPlayer) {
                if let videoURL = videoURL, let url = URL(string: videoURL) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .padding(.horizontal, CometChatSpacing.Padding.p1)
        .padding(.top, CometChatSpacing.Padding.p1)
        .onAppear {
            if let thumbnailImageUrl = thumbnailImageUrl {
                loadThumbnail(from: thumbnailImageUrl)
            } else if let videoURL = videoURL, let url = URL(string: videoURL) {
                generateThumbnail(from: url)
            }
        }
    }
    
    private var defaultThumbnailImage: UIImage {
        UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
    }
    
    private func playVideo() {
        if let videoURL = videoURL, !videoURL.isEmpty {
            showVideoPlayer = true
        }
    }
    
    private func loadThumbnail(from urlString: String) {
        guard thumbnailRetryCount < 5, let url = URL(string: urlString) else { return }
        
        isLoading = true
        
        let imageService = ImageService()
        imageService.image(for: url, cacheType: .normal) { image in
            isLoading = false
            if let image = image {
                thumbnailImage = image
            } else {
                thumbnailRetryCount += 1
                loadThumbnail(from: urlString)
            }
        }
    }
    
    private func generateThumbnail(from url: URL) {
        isLoading = true
        
        if let cacheImage = ImageService.imageCache.object(forKey: url as AnyObject) as? UIImage {
            thumbnailImage = cacheImage
            isLoading = false
            return
        }
        
        DispatchQueue.global().async {
            let asset = AVURLAsset(url: url)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            assetImgGenerate.requestedTimeToleranceBefore = .zero
            assetImgGenerate.requestedTimeToleranceAfter = .zero
            let time = CMTimeMake(value: 1, timescale: 1)
            
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                ImageService.imageCache.setObject(thumbnail, forKey: url as AnyObject)
                DispatchQueue.main.async {
                    thumbnailImage = thumbnail
                    isLoading = false
                }
            } catch {
                print("Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }
    
    public func set(thumbnailImageUrl: String) -> CometChatVideoBubbleSwiftUI {
        var view = self
        view.thumbnailImageUrl = thumbnailImageUrl
        return view
    }
    
    public func set(videoURL: String) -> CometChatVideoBubbleSwiftUI {
        var view = self
        view.videoURL = videoURL
        return view
    }
}

extension CometChatVideoBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatVideoBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatVideoBubbleSwiftUI()
                .set(videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
                .previewLayout(.fixed(width: 300, height: 200))
                .preferredColorScheme(.light)
            
            CometChatVideoBubbleSwiftUI()
                .set(videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
                .previewLayout(.fixed(width: 300, height: 200))
                .preferredColorScheme(.dark)
        }
    }
}
