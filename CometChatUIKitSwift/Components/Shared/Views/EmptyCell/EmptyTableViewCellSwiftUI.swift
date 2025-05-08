//
//
//

import SwiftUI
import CometChatSDK

public struct EmptyTableViewCellSwiftUI: View {
    
    @State private var customView: AnyView?
    
    public init() {}
    
    public var body: some View {
        VStack {
            if let customView = customView {
                customView
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear)
    }
    
    public func set<V: View>(customView: V) -> EmptyTableViewCellSwiftUI {
        var view = self
        view._customView = State(initialValue: AnyView(customView))
        return view
    }
}

extension EmptyTableViewCellSwiftUI {
    public func toUIKit() -> UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
}

struct EmptyTableViewCellSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyTableViewCellSwiftUI()
                .set(customView: 
                    Text("No items found")
                        .font(.headline)
                        .foregroundColor(.gray)
                )
                .previewLayout(.sizeThatFits)
                .frame(height: 100)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            EmptyTableViewCellSwiftUI()
                .set(customView: 
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                        Text("Search for items")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                )
                .previewLayout(.sizeThatFits)
                .frame(height: 100)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
