//
//
//

import SwiftUI
import CometChatSDK
import AVFoundation

public enum AudioRecordingState {
    case ready
    case recording
    case recorded
    case playing
    case paused
}

public struct CometChatMediaRecorderSwiftUI: View {
    
    @State private var currentState: AudioRecordingState = .ready
    @State private var totalSeconds: Int = 0
    @State private var totalFinalSeconds: Int = 0
    @State private var timerText: String = "00:00:00"
    @State private var isRecordingViewVisible: Bool = false
    @State private var audioURL: URL?
    
    private var style: MediaRecorderStyle = MediaRecorderStyle()
    private var onSubmit: ((String) -> Void)?
    @StateObject private var audioViewModel = MediaRecorderViewModel()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: CometChatSpacing.Spacing.s5) {
            VStack(spacing: 5) {
                if !isRecordingViewVisible {
                    ZStack {
                        Circle()
                            .fill(Color(style.recordingButtonBackgroundColor))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color(style.recordingButtonBorderColor), lineWidth: style.recordingButtonBorderWidth)
                            )
                        
                        Image(uiImage: style.recordingButtonImage)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(style.recordingButtonImageTintColor))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                    }
                    .frame(width: 120, height: 120)
                    
                    Text(timerText)
                        .font(Font(style.textFont))
                        .foregroundColor(Color(style.textColor))
                }
            }
            
            if isRecordingViewVisible, let url = audioURL {
                AudioBubbleView(url: url)
                    .frame(height: 60)
                    .padding(.horizontal)
                    .background(Color(CometChatMessageBubble.style.outgoing.audioBubbleStyle.backgroundColor ?? CometChatTheme.primaryColor))
                    .cornerRadius(CometChatSpacing.Radius.r3)
            }
            
            HStack(spacing: CometChatSpacing.Spacing.s5) {
                if currentState == .ready || currentState == .recording {
                    Button(action: deleteRecording) {
                        Image(uiImage: style.deleteButtonImage)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(style.deleteButtonImageTintColor))
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 40, height: 40)
                    .background(Color(style.deleteButtonBackgroundColor))
                    .cornerRadius(20)
                    .overlay(
                        Circle()
                            .stroke(Color(style.deleteButtonBorderColor), lineWidth: style.deleteButtonBorderWidth)
                    )
                    
                    if currentState == .ready || currentState == .paused {
                        Button(action: startRecording) {
                            Image(uiImage: style.startButtonImage)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(style.startButtonImageTintColor))
                                .frame(width: 24, height: 24)
                        }
                        .frame(width: 48, height: 48)
                        .background(Color(style.startButtonBackgroundColor))
                        .cornerRadius(24)
                        .overlay(
                            Circle()
                                .stroke(Color(style.startButtonBorderColor), lineWidth: style.startButtonBorderWidth)
                        )
                    } else if currentState == .recording {
                        Button(action: pauseRecording) {
                            Image(uiImage: style.pausebuttonImage)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(style.pauseButtonImageTintColor))
                                .frame(width: 24, height: 24)
                        }
                        .frame(width: 48, height: 48)
                        .background(Color(style.pauseButtonBackgroundColor))
                        .cornerRadius(24)
                        .overlay(
                            Circle()
                                .stroke(Color(style.pauseButtonBorderColor), lineWidth: style.pauseButtonBorderWidth)
                        )
                    }
                    
                    Button(action: stopRecording) {
                        Image(uiImage: style.stopButtonImage)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(style.stopButtonImageTintColor))
                            .frame(width: 24, height: 24)
                        
                    }
                    .frame(width: 40, height: 40)
                    .background(Color(style.stopButtonBackgroundColor))
                    .cornerRadius(20)
                    .overlay(
                        Circle()
                            .stroke(Color(style.stopButtonBorderColor), lineWidth: style.stopButtonBorderWidth)
                    )
                } else if currentState == .recorded {
                    Button(action: reRecordAudio) {
                        Image(uiImage: style.reRecordImage)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(style.reRecordButtonImageTintColor))
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 40, height: 40)
                    .background(Color(style.reRecordButtonBackgroundColor))
                    .cornerRadius(20)
                    .overlay(
                        Circle()
                            .stroke(Color(style.reRecordButtonBorderColor), lineWidth: style.reRecordButtonBorderWidth)
                    )
                    
                    Button(action: sendRecording) {
                        Image(uiImage: style.sendButtonImage)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(style.sendButtonImageTintColor))
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 48, height: 48)
                    .background(Color(style.sendButtonBackgroundColor))
                    .cornerRadius(24)
                    .overlay(
                        Circle()
                            .stroke(Color(style.sendButtonBorderColor), lineWidth: style.sendButtonBorderWidth)
                    )
                    
                    Button(action: deleteRecording) {
                        Image(uiImage: style.deleteButtonImage)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(style.deleteButtonImageTintColor))
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 40, height: 40)
                    .background(Color(style.deleteButtonBackgroundColor))
                    .cornerRadius(20)
                    .overlay(
                        Circle()
                            .stroke(Color(style.deleteButtonBorderColor), lineWidth: style.deleteButtonBorderWidth)
                    )
                }
            }
        }
        .padding()
        .background(Color(style.backgroundColor))
        .cornerRadius(style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r6)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r6)
                .stroke(Color(style.borderColor), lineWidth: style.borderWidth)
        )
        .onAppear {
            setupRecorder()
        }
        .onReceive(timer) { _ in
            if currentState == .recording {
                updateTimer()
            }
        }
    }
    
    private func setupRecorder() {
        audioViewModel.askAudioRecordingPermission { granted in
            if !granted {
            }
        }
    }
    
    private func updateTimer() {
        totalSeconds += 1
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        timerText = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func startRecording() {
        if currentState == .ready {
            audioViewModel.startRecording { _, error in
                if error == nil {
                    currentState = .recording
                }
            }
        } else if currentState == .paused {
            do {
                let duration = try audioViewModel.resume()
                totalSeconds = Int(duration)
                currentState = .recording
            } catch {
            }
        }
    }
    
    private func pauseRecording() {
        do {
            try audioViewModel.pause()
            currentState = .paused
        } catch {
        }
    }
    
    private func stopRecording() {
        do {
            try audioViewModel.stopRecording()
            currentState = .recorded
            isRecordingViewVisible = true
            
            if let url = audioViewModel.getRecordedAudioURL() {
                audioURL = url
            }
        } catch {
        }
    }
    
    private func deleteRecording() {
        do {
            try audioViewModel.resetRecording()
            currentState = .ready
            totalSeconds = 0
            timerText = "00:00:00"
            isRecordingViewVisible = false
            audioURL = nil
        } catch {
        }
    }
    
    private func reRecordAudio() {
        deleteRecording()
        startRecording()
    }
    
    private func sendRecording() {
        if let url = audioURL {
            onSubmit?(url.absoluteString)
        }
    }
    
    public func set(style: MediaRecorderStyle) -> CometChatMediaRecorderSwiftUI {
        var view = self
        view.style = style
        return view
    }
    
    public func set(onSubmit: @escaping ((String) -> Void)) -> CometChatMediaRecorderSwiftUI {
        var view = self
        view.onSubmit = onSubmit
        return view
    }
}

struct AudioBubbleView: View {
    let url: URL
    
    var body: some View {
        HStack {
            Button(action: {
            }) {
                Image(systemName: "play.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)
            .background(Color.blue)
            .clipShape(Circle())
            
            HStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 3, height: CGFloat.random(in: 5...30))
                }
            }
            
            Spacer()
            
            Text("0:30")
                .foregroundColor(.white)
                .font(.caption)
        }
        .padding(.horizontal)
    }
}

class MediaRecorderViewModel: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    
    func askAudioRecordingPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
    
    func startRecording(completion: @escaping (URL?, Error?) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording-\(Date().timeIntervalSince1970).m4a")
            recordingURL = audioFilename
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            completion(audioFilename, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func pause() throws -> TimeInterval {
        guard let recorder = audioRecorder else {
            throw NSError(domain: "AudioRecorderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No active recorder"])
        }
        
        recorder.pause()
        return recorder.currentTime
    }
    
    func resume() throws -> TimeInterval {
        guard let recorder = audioRecorder else {
            throw NSError(domain: "AudioRecorderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No active recorder"])
        }
        
        recorder.record()
        return recorder.currentTime
    }
    
    func stopRecording() throws {
        guard let recorder = audioRecorder else {
            throw NSError(domain: "AudioRecorderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No active recorder"])
        }
        
        recorder.stop()
    }
    
    func resetRecording() throws {
        try stopRecording()
        audioRecorder = nil
        recordingURL = nil
    }
    
    func getRecordedAudioURL() -> URL? {
        return recordingURL
    }
}

extension CometChatMediaRecorderSwiftUI {
    public func toUIKit() -> UIViewController {
        let hostingController = UIHostingController(rootView: self)
        return hostingController
    }
}

struct CometChatMediaRecorderSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatMediaRecorderSwiftUI()
                .previewLayout(.sizeThatFits)
                .frame(height: 300)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode - Ready State")
            
            CometChatMediaRecorderSwiftUI()
                .previewLayout(.sizeThatFits)
                .frame(height: 300)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode - Ready State")
        }
    }
}
