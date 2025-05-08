//
//
//

import SwiftUI
import CometChatSDK

public enum LiveReactionType {
    case heart
    case thumbsup
}

public struct CometChatLiveReactionSwiftUI: View {
    
    @State private var isAnimating: Bool = false
    @State private var floatingEmojis: [FloatingEmoji] = []
    
    private var image1: UIImage?
    private var duration: Double = 1.0
    private var duration1: Double = 2.0
    private var duration2: Double = 2.0
    private var floatieSize = CGSize(width: 50, height: 50)
    private var floatieDelay: Double = 10
    private var delay: Double = 10.0
    private var startingAlpha: CGFloat = 1.0
    private var endingAlpha: CGFloat = 0.0
    private var upwards: Bool = true
    private var remove: Bool = true
    private var removeAtEnd: Bool = true
    private var floatingUp: Bool = true
    private var alphaAtStart: CGFloat = 1.0
    private var alphaAtEnd: CGFloat = 0.0
    private var rotationSpeed: Double = 10
    private var density: Double = 10
    private var delayedStart: Double = 10
    private var speedY: CGFloat = 10
    private var speedX: CGFloat = 5
    private var floatieWidth: CGFloat = 50
    private var floatieHeight: CGFloat = 50
    private var borderColor: Color = Color.clear
    private var borderWidth: CGFloat = 0
    private var cornerRadius: CGFloat = 0
    
    public init() {
        self.image1 = UIImage(named: "heart", in: CometChatUIKit.bundle, compatibleWith: nil)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(floatingEmojis, id: \.id) { emoji in
                    Image(uiImage: emoji.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: floatieSize.width, height: floatieSize.height)
                        .position(emoji.position)
                        .opacity(emoji.opacity)
                        .rotationEffect(Angle(degrees: emoji.rotation))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(cornerRadius)
        }
    }
    
    public func set(floaterImage: UIImage?) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.image1 = floaterImage
        return view
    }
    
    public func set(removeAtEnd: Bool) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.removeAtEnd = removeAtEnd
        view.remove = removeAtEnd
        return view
    }
    
    public func set(floatingUp: Bool) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.floatingUp = floatingUp
        view.upwards = floatingUp
        return view
    }
    
    public func set(alphaAtStart: CGFloat) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.alphaAtStart = alphaAtStart
        view.startingAlpha = alphaAtStart
        return view
    }
    
    public func set(alphaAtEnd: CGFloat) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.alphaAtEnd = alphaAtEnd
        view.endingAlpha = alphaAtEnd
        return view
    }
    
    public func set(rotationSpeed: Double) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.rotationSpeed = rotationSpeed
        view.duration2 = 20 / rotationSpeed
        return view
    }
    
    public func set(density: Double) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.density = density
        view.floatieDelay = 1 / density
        return view
    }
    
    public func set(delayedStart: Double) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.delayedStart = delayedStart
        view.delay = delayedStart
        return view
    }
    
    public func set(speedY: CGFloat) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.speedY = speedY
        view.duration = Double(10/speedY)
        return view
    }
    
    public func set(speedX: CGFloat) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.speedX = speedX
        view.duration1 = Double(10/speedX)
        return view
    }
    
    public func set(floatieWidth: CGFloat) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.floatieWidth = floatieWidth
        view.floatieSize.width = floatieWidth
        return view
    }
    
    public func set(floatieHeight: CGFloat) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.floatieHeight = floatieHeight
        view.floatieSize.height = floatieHeight
        return view
    }
    
    public func set(borderColor: UIColor) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.borderColor = Color(borderColor)
        return view
    }
    
    public func set(borderWidth: CGFloat) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.borderWidth = borderWidth
        return view
    }
    
    public func set(cornerRadius: CGFloat) -> CometChatLiveReactionSwiftUI {
        var view = self
        view.cornerRadius = cornerRadius
        return view
    }
    
    public func sendReaction() -> CometChatLiveReactionSwiftUI {
        var view = self
        view.isAnimating = true
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if view.isAnimating {
                view.addFloatingEmoji()
            } else {
                timer.invalidate()
            }
        }
        
        return view
    }
    
    public func stopReaction() -> CometChatLiveReactionSwiftUI {
        var view = self
        view.isAnimating = false
        view.floatingEmojis = []
        return view
    }
    
    public func buildDefaultSetting() -> CometChatLiveReactionSwiftUI {
        var view = self
        view.floatingUp = true
        view.alphaAtStart = 1
        view.alphaAtEnd = 0
        view.rotationSpeed = 3
        view.density = 7
        view.delayedStart = 0
        view.speedX = 50
        view.speedY = 8
        view.floatieWidth = 30
        view.floatieHeight = 30
        view.borderWidth = 0
        view.cornerRadius = 25
        return view
    }
    
    private func addFloatingEmoji() {
        guard let image = self.image1 else { return }
        
        let randomX = CGFloat.random(in: floatieSize.width/2...UIScreen.main.bounds.width - floatieSize.width/2)
        let startY = upwards ? UIScreen.main.bounds.height : 0
        let endY = upwards ? floatieSize.height*2 : UIScreen.main.bounds.height - floatieSize.height*2
        
        let randomRotation = Bool.random() ? -1.0 : 1.0
        let xChange = randomX < UIScreen.main.bounds.width/2 ?
            randomX + CGFloat.random(in: randomX...UIScreen.main.bounds.width-randomX) :
            CGFloat.random(in: floatieSize.width*2...randomX)
        
        let emoji = FloatingEmoji(
            id: UUID(),
            image: image,
            position: CGPoint(x: randomX, y: startY),
            targetPosition: CGPoint(x: xChange, y: endY),
            opacity: startingAlpha,
            rotation: 0
        )
        
        floatingEmojis.append(emoji)
        
        withAnimation(Animation.linear(duration: duration)) {
            if let index = floatingEmojis.firstIndex(where: { $0.id == emoji.id }) {
                floatingEmojis[index].position.y = endY
                floatingEmojis[index].opacity = endingAlpha
            }
        }
        
        withAnimation(Animation.linear(duration: duration1).repeatForever(autoreverses: true)) {
            if let index = floatingEmojis.firstIndex(where: { $0.id == emoji.id }) {
                floatingEmojis[index].position.x = xChange
            }
        }
        
        withAnimation(Animation.linear(duration: duration2).repeatForever(autoreverses: true)) {
            if let index = floatingEmojis.firstIndex(where: { $0.id == emoji.id }) {
                floatingEmojis[index].rotation = 90 * randomRotation
            }
        }
        
        if removeAtEnd {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                floatingEmojis.removeAll { $0.id == emoji.id }
            }
        }
    }
}

struct FloatingEmoji {
    let id: UUID
    let image: UIImage
    var position: CGPoint
    let targetPosition: CGPoint
    var opacity: CGFloat
    var rotation: Double
}

extension CometChatLiveReactionSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct CometChatLiveReactionSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CometChatLiveReactionSwiftUI()
                .buildDefaultSetting()
                .set(floaterImage: UIImage(systemName: "heart.fill"))
                .frame(width: 300, height: 400)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            CometChatLiveReactionSwiftUI()
                .buildDefaultSetting()
                .set(floaterImage: UIImage(systemName: "heart.fill"))
                .frame(width: 300, height: 400)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
