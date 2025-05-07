//
//  
//
//

import SwiftUI
import Foundation
import CometChatSDK

#if canImport(CometChatCallsSDK)

public class CallingConfigurationSwiftUI {
    
    var incomingCallConfiguration: IncomingCallConfiguration?
    var outgoingCallConfiguration: OutgoingCallConfiguration?
    var callBubbleConfiguration: CallBubbleConfiguration?
    var callButtonConfiguration: CallButtonConfiguration?
    var groupCallSettingsBuilder: ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)?
    
    public init() { }
    
    @discardableResult
    public func set(incomingCallConfiguration: IncomingCallConfiguration) -> Self {
        self.incomingCallConfiguration = incomingCallConfiguration
        return self
    }
    
    @discardableResult
    public func set(outgoingCallConfiguration: OutgoingCallConfiguration) -> Self {
        self.outgoingCallConfiguration = outgoingCallConfiguration
        return self
    }
    
    @discardableResult public func set(groupCallSettingsBuilder: @escaping ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)) -> Self {
        self.groupCallSettingsBuilder = groupCallSettingsBuilder
        return self
    }
    
    @discardableResult
    public func set(callBubbleConfiguration: CallBubbleConfiguration) -> Self {
        self.callBubbleConfiguration = callBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(callButtonConfiguration: CallButtonConfiguration) -> Self {
        self.callButtonConfiguration = callButtonConfiguration
        return self
    }
    
    public func toUIKit() -> CallingConfiguration {
        let configuration = CallingConfiguration()
        
        if let incomingCallConfiguration = incomingCallConfiguration {
            configuration.set(incomingCallConfiguration: incomingCallConfiguration)
        }
        
        if let outgoingCallConfiguration = outgoingCallConfiguration {
            configuration.set(outgoingCallConfiguration: outgoingCallConfiguration)
        }
        
        if let callBubbleConfiguration = callBubbleConfiguration {
            configuration.set(callBubbleConfiguration: callBubbleConfiguration)
        }
        
        if let callButtonConfiguration = callButtonConfiguration {
            configuration.set(callButtonConfiguration: callButtonConfiguration)
        }
        
        if let groupCallSettingsBuilder = groupCallSettingsBuilder {
            configuration.set(groupCallSettingsBuilder: groupCallSettingsBuilder)
        }
        
        return configuration
    }
    
    public static func from(uiKitConfiguration: CallingConfiguration) -> CallingConfigurationSwiftUI {
        let configuration = CallingConfigurationSwiftUI()
        
        configuration.incomingCallConfiguration = uiKitConfiguration.incomingCallConfiguration
        configuration.outgoingCallConfiguration = uiKitConfiguration.outgoingCallConfiguration
        configuration.callBubbleConfiguration = uiKitConfiguration.callBubbleConfiguration
        configuration.callButtonConfiguration = uiKitConfiguration.callButtonConfiguration
        configuration.groupCallSettingsBuilder = uiKitConfiguration.groupCallSettingsBuilder
        
        return configuration
    }
}

#endif
