//
//
//

import SwiftUI
import QuickLook
import CometChatSDK

public struct CometChatFileBubbleSwiftUI: View {
    private var style: FileBubbleStyle
    private var fileUrl: String?
    private var cacheFileUrl: String?
    private var title: String?
    private var subtitle: String?
    private var fileIcon: UIImage?
    
    @State private var isDownloading: Bool = false
    @State private var downloadProgress: Float = 0.0
    @State private var previewItemURL: URL?
    @State private var showQuickLook: Bool = false
    @State private var urlSessionDownloadTask: URLSessionDownloadTask?
    
    public init(style: FileBubbleStyle = FileBubbleStyle()) {
        self.style = style
    }
    
    public var body: some View {
        HStack(spacing: CometChatSpacing.Spacing.s2) {
            Image(uiImage: fileIcon ?? UIImage(named: "cometchat_unknown_file_icon", in: CometChatUIKit.bundle, with: nil)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: CometChatSpacing.Spacing.s1) {
                if let title = title {
                    Text(title)
                        .font(Font(style.titleFont))
                        .foregroundColor(Color(style.titleColor))
                        .lineLimit(1)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Font(style.subtitleFont))
                        .foregroundColor(Color(style.subtitleColor))
                        .lineLimit(1)
                }
            }
            .padding(.leading, CometChatSpacing.Padding.p1)
            
            Spacer()
            
            if let _ = previewItemURL {
                EmptyView()
            } else if isDownloading {
                ZStack {
                    Circle()
                        .stroke(Color(style.downloadTintColor).opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(downloadProgress))
                        .stroke(Color(style.downloadTintColor), lineWidth: 2)
                        .frame(width: 22, height: 22)
                        .rotationEffect(.degrees(-90))
                    
                    Button(action: {
                        cancelDownload()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundColor(Color(style.downloadTintColor))
                    }
                    .frame(width: 22, height: 22)
                }
            } else {
                Button(action: {
                    downloadFile()
                }) {
                    Image(uiImage: UIImage(named: "download", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "arrow.down.circle")!)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(style.downloadTintColor))
                        .frame(width: 22, height: 22)
                }
            }
        }
        .padding(CometChatSpacing.Padding.p2)
        .frame(maxWidth: 232)
        .onTapGesture {
            if let previewItemURL = previewItemURL {
                showQuickLook = true
            } else if let fileUrl = fileUrl, let url = URL(string: fileUrl) {
                checkIfFileExists(url: url) { exists, localURL in
                    if exists, let localURL = localURL {
                        self.previewItemURL = localURL
                        self.showQuickLook = true
                    } else {
                        downloadFile()
                    }
                }
            }
        }
        .quickLookPreview($previewItemURL, in: [previewItemURL].compactMap { $0 })
        .onAppear {
            checkForExistingFile()
        }
    }
    
    private func checkForExistingFile() {
        if let cacheFileUrl = cacheFileUrl, let url = URL(string: cacheFileUrl) {
            checkIfFileExists(url: url, isLocalURL: true) { exists, localURL in
                if exists, let localURL = localURL {
                    self.previewItemURL = localURL
                }
            }
        } else if let fileUrl = fileUrl, let url = URL(string: fileUrl) {
            checkIfFileExists(url: url) { exists, localURL in
                if exists, let localURL = localURL {
                    self.previewItemURL = localURL
                }
            }
        }
    }
    
    private func checkIfFileExists(url: URL, isLocalURL: Bool = false, completion: @escaping (Bool, URL?) -> Void) {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else if isLocalURL {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.copyItem(at: url, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch {
                    completion(false, nil)
                }
            } else {
                completion(false, nil)
            }
        } else {
            completion(false, nil)
        }
    }
    
    private func downloadFile() {
        guard let fileUrl = fileUrl, let url = URL(string: fileUrl), !isDownloading else { return }
        
        isDownloading = true
        downloadProgress = 0.0
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        
        urlSessionDownloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let tempLocation = location, error == nil else {
                DispatchQueue.main.async {
                    self.isDownloading = false
                }
                return
            }
            
            do {
                try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                DispatchQueue.main.async {
                    self.previewItemURL = destinationUrl
                    self.isDownloading = false
                    self.showQuickLook = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isDownloading = false
                }
            }
        }
        
        urlSessionDownloadTask?.resume()
        
        let observation = urlSessionDownloadTask?.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.downloadProgress = Float(progress.fractionCompleted)
            }
        }
        
        _ = observation
    }
    
    private func cancelDownload() {
        urlSessionDownloadTask?.cancel()
        urlSessionDownloadTask = nil
        isDownloading = false
    }
    
    public func set(fileUrl: String) -> CometChatFileBubbleSwiftUI {
        var view = self
        view.fileUrl = fileUrl
        return view
    }
    
    public func set(cacheFileUrl: String) -> CometChatFileBubbleSwiftUI {
        var view = self
        view.cacheFileUrl = cacheFileUrl
        return view
    }
    
    public func set(title: String) -> CometChatFileBubbleSwiftUI {
        var view = self
        view.title = title
        return view
    }
    
    public func set(subtitle: String) -> CometChatFileBubbleSwiftUI {
        var view = self
        view.subtitle = subtitle
        return view
    }
    
    public func set(fileIcon: UIImage) -> CometChatFileBubbleSwiftUI {
        var view = self
        view.fileIcon = fileIcon
        return view
    }
    
    public static func getFileIcon(for mediaMessage: MediaMessage, localURL: URL? = nil) -> UIImage? {
        let bundle = CometChatUIKit.bundle
        
        let wordFileIcon = UIImage(named: "cometchat_word_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let pptFileIcon = UIImage(named: "cometchat_ppt_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let xlsxFileIcon = UIImage(named: "cometchat_xlsx_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let pdfFileIcon = UIImage(named: "cometchat_pdf_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let zipFileIcon = UIImage(named: "cometchat_zip_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let textFileIcon = UIImage(named: "cometchat_text_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let audioFileIcon = UIImage(named: "cometchat_audio_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let imageFileIcon = UIImage(named: "cometchat_image_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let videoFileIcon = UIImage(named: "cometchat_video_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let linkFileIcon = UIImage(named: "cometchat_link_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        let unknownFileIcon = UIImage(named: "cometchat_unknown_file_icon", in: bundle, with: nil)?.withRenderingMode(.alwaysOriginal)
        
        func getFileIcon(for fileExtension: String?) -> UIImage? {
            guard let fileExtension = fileExtension else { return nil }
            switch fileExtension.lowercased() {
            case "doc", "docx":
                return wordFileIcon
            case "ppt", "pptx":
                return pptFileIcon
            case "xls", "xlsx":
                return xlsxFileIcon
            case "pdf":
                return pdfFileIcon
            case "zip":
                return zipFileIcon
            case "csv":
                return textFileIcon
            case "mp3", "wav", "aac":
                return audioFileIcon
            case "jpg", "jpeg", "png", "gif":
                return imageFileIcon
            case "mp4", "mov":
                return videoFileIcon
            case "txt":
                return textFileIcon
            case "html", "url":
                return linkFileIcon
            default:
                return nil
            }
        }
        
        if let imageFromLocalURL = getFileIcon(for: localURL?.pathExtension) {
            return imageFromLocalURL
        }
        
        if let attachment = mediaMessage.attachment {
            let mimeType = attachment.fileMimeType
            
            if mimeType.contains("video") {
                return videoFileIcon
            } else if mimeType.contains("octet-stream") {
                if attachment.fileUrl.hasSuffix(".doc") {
                    return wordFileIcon
                } else if attachment.fileUrl.hasSuffix(".ppt") {
                    return pptFileIcon
                } else if attachment.fileUrl.hasSuffix(".xls") {
                    return xlsxFileIcon
                }
            } else if mimeType.contains("pdf") {
                return pdfFileIcon
            } else if mimeType.contains("zip") {
                return zipFileIcon
            } else if attachment.fileUrl.contains(".csv") {
                return textFileIcon
            } else if mimeType.contains("audio") {
                return audioFileIcon
            } else if mimeType.contains("image") {
                return imageFileIcon
            } else if mimeType.contains("text") {
                return textFileIcon
            } else if mimeType.contains("link") {
                return linkFileIcon
            }
        }
        
        return unknownFileIcon
    }
}

extension CometChatFileBubbleSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatFileBubbleSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                CometChatFileBubbleSwiftUI()
                    .set(title: "Document.pdf")
                    .set(subtitle: "2.5 MB")
                    .set(fileIcon: UIImage(named: "cometchat_pdf_file_icon", in: CometChatUIKit.bundle, with: nil)!)
                    .set(fileUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")
                
                CometChatFileBubbleSwiftUI()
                    .set(title: "Presentation.pptx")
                    .set(subtitle: "5.7 MB")
                    .set(fileIcon: UIImage(named: "cometchat_ppt_file_icon", in: CometChatUIKit.bundle, with: nil)!)
                
                CometChatFileBubbleSwiftUI()
                    .set(title: "Spreadsheet.xlsx")
                    .set(subtitle: "1.2 MB")
                    .set(fileIcon: UIImage(named: "cometchat_xlsx_file_icon", in: CometChatUIKit.bundle, with: nil)!)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            VStack(spacing: 20) {
                CometChatFileBubbleSwiftUI()
                    .set(title: "Document.pdf")
                    .set(subtitle: "2.5 MB")
                    .set(fileIcon: UIImage(named: "cometchat_pdf_file_icon", in: CometChatUIKit.bundle, with: nil)!)
                    .set(fileUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")
                
                CometChatFileBubbleSwiftUI()
                    .set(title: "Presentation.pptx")
                    .set(subtitle: "5.7 MB")
                    .set(fileIcon: UIImage(named: "cometchat_ppt_file_icon", in: CometChatUIKit.bundle, with: nil)!)
                
                CometChatFileBubbleSwiftUI()
                    .set(title: "Spreadsheet.xlsx")
                    .set(subtitle: "1.2 MB")
                    .set(fileIcon: UIImage(named: "cometchat_xlsx_file_icon", in: CometChatUIKit.bundle, with: nil)!)
            }
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
