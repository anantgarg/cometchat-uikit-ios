//
//
//

import SwiftUI
import CometChatSDK
import CometChatUIKitSwift.Components.Shared.Constants

protocol StickerViewDelegateSwiftUI {
    func didStickerSelected(sticker: CometChatSticker)
    func didStickerSetSelected(stickerSet: CometChatStickerSet)
}

protocol StickerkeyboardDelegateSwiftUI {
    func showStickerKeyboard(status: Bool)
}

struct StickerCellSwiftUI: View {
    var sticker: CometChatSticker?
    var stickerSet: CometChatStickerSet?
    
    var body: some View {
        Group {
            if let sticker = sticker, let url = URL(string: sticker.url) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: LayoutMetrics.avatarLarge + LayoutMetrics.spacingMedium, height: LayoutMetrics.avatarLarge + LayoutMetrics.spacingMedium)
            } else if let stickerSet = stickerSet, let stickers = stickerSet.stickers, let firstSticker = stickers.first, let url = URL(string: firstSticker.url) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: LayoutMetrics.mediumIconSize + LayoutMetrics.spacingMedium, height: LayoutMetrics.mediumIconSize + LayoutMetrics.spacingMedium)
            } else {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .frame(width: LayoutMetrics.mediumIconSize + LayoutMetrics.spacingMedium, height: LayoutMetrics.mediumIconSize + LayoutMetrics.spacingMedium)
            }
        }
    }
}

public struct CometChatStickerKeyboardSwiftUI: View {
    
    @State private var stickerSet: [CometChatStickerSet] = []
    @State private var stickersForPreview: [CometChatSticker] = []
    @State private var allstickers: [CometChatSticker] = []
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var onStickerTap: ((CometChatSticker) -> Void)?
    @State private var onStickerSetSelected: ((CometChatStickerSet) -> Void)?
    @State private var selectedStickerSetIndex: Int = 0
    
    static var stickerDelegate: StickerViewDelegateSwiftUI?
    static var stickerkeyboardDelegate: StickerkeyboardDelegateSwiftUI?
    
    public init() {
        fetchStickers()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(CometChatTheme.palatte.accent100))
                .frame(height: 1)
            
            if isLoading {
                loadingView
            } else if showError {
                errorView
            } else if stickerSet.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .frame(height: LayoutMetrics.loadingContentHeight * 4)
        .background(Color(CometChatTheme.palatte.background))
    }
    
    private var contentView: some View {
        VStack(spacing: LayoutMetrics.spacingStandard) {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: LayoutMetrics.spacingMedium), count: 4), spacing: LayoutMetrics.spacingLarge) {
                    ForEach(stickersForPreview.indices, id: \.self) { index in
                        StickerCellSwiftUI(sticker: stickersForPreview[index])
                            .onTapGesture {
                                let sticker = stickersForPreview[index]
                                onStickerTap?(sticker)
                                CometChatStickerKeyboardSwiftUI.stickerDelegate?.didStickerSelected(sticker: sticker)
                                CometChatStickerKeyboardSwiftUI.stickerkeyboardDelegate?.showStickerKeyboard(status: false)
                            }
                    }
                }
                .padding(.horizontal, LayoutMetrics.spacingStandard)
                .padding(.vertical, LayoutMetrics.spacingStandard)
            }
            
            Rectangle()
                .fill(Color(CometChatTheme.palatte.accent100))
                .frame(height: 1)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(32))], spacing: CometChatSpacing.Spacing.s4) {
                    ForEach(stickerSet.indices, id: \.self) { index in
                        StickerCellSwiftUI(stickerSet: stickerSet[index])
                            .onTapGesture {
                                selectedStickerSetIndex = index
                                if let stickerSet = stickerSet[safe: index], let stickers = stickerSet.stickers {
                                    stickersForPreview = stickers
                                    onStickerSetSelected?(stickerSet)
                                    CometChatStickerKeyboardSwiftUI.stickerDelegate?.didStickerSetSelected(stickerSet: stickerSet)
                                }
                            }
                            .background(selectedStickerSetIndex == index ? Color(CometChatTheme.palatte.accent100).opacity(0.3) : Color.clear)
                            .cornerRadius(LayoutMetrics.cornerRadiusLarge)
                    }
                }
                .padding(.horizontal, LayoutMetrics.spacingStandard)
                .padding(.vertical, LayoutMetrics.spacingStandard)
                .frame(height: LayoutMetrics.avatarLarge)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Loading...")
                .font(.caption)
                .foregroundColor(Color(CometChatTheme.palatte.accent600))
                .padding(.top, LayoutMetrics.spacingStandard)
            Spacer()
        }
    }
    
    private var errorView: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(Color(CometChatTheme.palatte.error))
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(Color(CometChatTheme.palatte.accent600))
                .multilineTextAlignment(.center)
            
            Button(action: {
                retry()
            }) {
                Text("Retry")
                    .font(.footnote.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, LayoutMetrics.spacingLarge)
                    .padding(.vertical, LayoutMetrics.spacingStandard)
                    .background(Color(CometChatTheme.palatte.primary))
                    .cornerRadius(LayoutMetrics.cornerRadiusStandard)
            }
            Spacer()
        }
        .padding()
    }
    
    private var emptyView: some View {
        VStack(spacing: LayoutMetrics.spacingLarge) {
            Spacer()
            Image(systemName: "photo.on.rectangle.angled")
                .font(.largeTitle)
                .foregroundColor(Color(CometChatTheme.palatte.accent400))
            
            Text("No Stickers Found")
                .font(.headline)
                .foregroundColor(Color(CometChatTheme.palatte.accent600))
            
            Text("There are no stickers available at the moment.")
                .font(.caption)
                .foregroundColor(Color(CometChatTheme.palatte.accent500))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
    
    private func fetchStickers() {
        isLoading = true
        showError = false
        
        CometChat.callExtension(slug: ExtensionConstants.stickers, type: .get, endPoint: "v1/fetch", params: nil) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let response):
                    if let response = response as? [String: Any], let data = response["data"] as? [String: Any], let stickerSets = data["sticker_sets"] as? [[String: Any]], let customStickers = data["custom_stickers"] as? [[String: Any]] {
                        parseStickersSet(stickerSets: stickerSets, customStickerSet: customStickers) { dictionary in
                            self.stickerSet = dictionary.map { CometChatStickerSet(name: $0.key, stickers: $0.value) }
                            if let firstSet = self.stickerSet.first, let stickers = firstSet.stickers {
                                self.stickersForPreview = stickers
                            }
                        }
                    } else {
                        showError = true
                        errorMessage = "Failed to parse stickers data"
                    }
                    
                case .failure(let error):
                    showError = true
                    errorMessage = error.errorDescription
                }
            }
        }
    }
    
    private func parseStickersSet(stickerSets: [[String: Any]], customStickerSet: [[String: Any]], onSuccess: @escaping ([String: [CometChatSticker]]) -> Void) {
        var stickers: [CometChatSticker] = []
        var allstickers: [CometChatSticker] = []
        
        stickerSets.forEach { stickerData in
            if let stickerList = stickerData["stickers"] as? [[String: Any]] {
                stickerList.forEach { stickerInfo in
                    let sticker = CometChatSticker(id: stickerInfo["id"] as? String ?? "", name: stickerInfo["stickerName"] as? String ?? "", order: stickerInfo["stickerOrder"] as? Int ?? 0, setID: stickerInfo["stickerSetId"] as? String ?? "", setName: stickerInfo["stickerSetName"] as? String ?? "", setOrder: stickerInfo["stickerSetOrder"] as? Int ?? 0, url: stickerInfo["stickerUrl"] as? String ?? "")
                    stickers.append(sticker)
                    allstickers.append(sticker)
                }
            }
        }
        
        customStickerSet.forEach { stickerData in
            let sticker = CometChatSticker(id: stickerData["id"] as? String ?? "", name: stickerData["stickerName"] as? String ?? "", order: stickerData["stickerOrder"] as? Int ?? 0, setID: stickerData["stickerSetId"] as? String ?? "", setName: stickerData["stickerSetName"] as? String ?? "", setOrder: stickerData["stickerSetOrder"] as? Int ?? 0, url: stickerData["stickerUrl"] as? String ?? "")
            stickers.append(sticker)
            allstickers.append(sticker)
        }
        
        let dictionary = Dictionary(grouping: stickers, by: { $0.setName })
        onSuccess(dictionary)
    }
    
    private func retry() {
        fetchStickers()
    }
    
    @discardableResult
    public func setOnStickerTap(onStickerTap: @escaping (_ sticker: CometChatSticker) -> Void) -> Self {
        var view = self
        view._onStickerTap = State(initialValue: onStickerTap)
        return view
    }
    
    @discardableResult
    public func setOnStickerSetSelected(onStickerSetSelected: @escaping (_ stickerSet: CometChatStickerSet) -> Void) -> Self {
        var view = self
        view._onStickerSetSelected = State(initialValue: onStickerSetSelected)
        return view
    }
    
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        let view = hostingController.view
        view?.translatesAutoresizingMaskIntoConstraints = false
        view?.heightAnchor.constraint(equalToConstant: 250).isActive = true
        return view ?? UIView()
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct CometChatStickerKeyboardSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatStickerKeyboardSwiftUI()
                .frame(width: 375, height: 250)
                .previewDisplayName("Sticker Keyboard (Light)")
            
            CometChatStickerKeyboardSwiftUI()
                .frame(width: 375, height: 250)
                .preferredColorScheme(.dark)
                .previewDisplayName("Sticker Keyboard (Dark)")
        }
    }
}
