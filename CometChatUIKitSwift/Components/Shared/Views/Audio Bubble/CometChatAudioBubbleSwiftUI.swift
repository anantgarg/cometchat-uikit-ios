//
//
//

import SwiftUI
import AVFoundation
import CometChatSDK

public struct CometChatAudioBubbleSwiftUI: View {
    private var style: AudioBubbleStyle
    private var fileURL: String?
    private var fileSize: Double?
    
    @State private var isPlaying: Bool = false
    @State private var currentTime: String = "00:00"
    @State private var duration: String = "--:--"
    @State private var isAnimating: Bool = false
    @State private var player: AVPlayer?
    @State private var timeObserverToken: Any?
    
    public init(style: AudioBubbleStyle = AudioBubbleStyle()) {
        self.style = style
    }
    
    public var body: some View {
        HStack(spacing: CometChatSpacing.Padding.p3) {
            Button(action: {
                onPlayPauseClicked()
            }) {
                Circle()
                    .fill(Color(style.playImageBackgroundColor))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(style.playImageTintColor))
                    )
            }
            
            VStack(alignment: .leading, spacing: CometChatSpacing.Spacing.s2) {
                if isAnimating {
                    GIFImageViewRepresentable(
                        gifName: "audio-waveform",
                        tintColor: style.audioWaveFormTintIcon
                    )
                    .frame(height: 24)
                } else {
                    Image("audio-waveform-static", bundle: CometChatUIKit.bundle)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                        .foregroundColor(Color(style.audioWaveFormTintIcon))
                }
                
                Text(fileSize != nil ? "\(String(format: "%.2f", (fileSize ?? 0)/1_048_576)) MB" : "\(currentTime)/\(duration)")
                    .font(Font(style.audioTimeLineFont))
                    .foregroundColor(Color(style.audioTimeLineTextColor))
            }
        }
        .padding(.horizontal, CometChatSpacing.Padding.p3)
        .padding(.vertical, CometChatSpacing.Padding.p3)
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    private func setupAudioPlayer() {
        guard let fileURL = fileURL, let url = URL(string: fileURL) else { return }
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(url: url)
        
        let durationInSeconds = asset.duration.seconds
        duration = formatTime(seconds: durationInSeconds)
        
        player = AVPlayer(playerItem: playerItem)
        
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let currentTimeInSeconds = CMTimeGetSeconds(time)
            currentTime = formatTime(seconds: currentTimeInSeconds)
        }
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            stopPlayback()
        }
    }
    
    private func onPlayPauseClicked() {
        guard let player = player else {
            setupAudioPlayer()
            return
        }
        
        if isPlaying {
            player.pause()
            isPlaying = false
            isAnimating = false
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("AudioBubblePlaybackStarted"), object: nil)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Error setting up audio session: \(error.localizedDescription)")
            }
            
            player.seek(to: player.currentTime())
            player.play()
            isPlaying = true
            isAnimating = true
        }
    }
    
    private func stopPlayback() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        isAnimating = false
        
        if let token = timeObserverToken, let player = player {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    private func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public func set(fileURL: String) -> CometChatAudioBubbleSwiftUI {
        var view = self
        view.fileURL = fileURL
        return view
    }
    
    public func set(fileSize: Double) -> CometChatAudioBubbleSwiftUI {
        var view = self
        view.fileSize = fileSize
        return view
    }
}

struct GIFImageViewRepresentable: UIViewRepresentable {
    let gifName: String
    let tintColor: UIColor
    
    func makeUIView(context: Context) -> GIFImageView {
        let gifView = GIFImageView()
        
        if let url = CometChatUIKit.bundle.url(forResource: gifName, withExtension: "gif"),
           let data = NSData(contentsOf: url) {
            gifView.setGIFData(data, tintColor: tintColor)
            gifView.startAnimation()
        }
        
        return gifView
    }
    
    func updateUIView(_ uiView: GIFImageView, context: Context) {
    }
}

extension CometChatAudioBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        
        NotificationCenter.default.addObserver(
            hostingController,
            selector: #selector(UIHostingController.stopAudioPlayback),
            name: NSNotification.Name("AudioBubblePlaybackStarted"),
            object: nil
        )
        
        return hostingController.view
    }
}

extension UIHostingController {
    @objc func stopAudioPlayback() {
        NotificationCenter.default.post(name: NSNotification.Name("StopCurrentAudioPlayback"), object: nil)
    }
}

struct CometChatAudioBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatAudioBubbleSwiftUI()
                .set(fileURL: "https://file-examples.com/storage/fe8c7eef0c6364f6c9504cc/2017/11/file_example_MP3_700KB.mp3")
                .previewLayout(.fixed(width: 300, height: 100))
                .preferredColorScheme(.light)
            
            CometChatAudioBubbleSwiftUI()
                .set(fileSize: 1024 * 1024 * 2.5) // 2.5 MB
                .previewLayout(.fixed(width: 300, height: 100))
                .preferredColorScheme(.dark)
        }
    }
}
