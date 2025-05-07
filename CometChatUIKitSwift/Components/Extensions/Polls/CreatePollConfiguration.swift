//
//  CreatePollConfiguration.swift
//
//
//  Created by Abdullah Ansari on 23/08/22.
//

import UIKit

public class CreatePollConfiguration {
    private(set) var closeIcon: UIImage?
    private(set) var createPollIcon: UIImage?
    private(set) var deleteIcon: UIImage?
    private(set) var onCreatePoll: (() -> Void)?
    private(set) var onClose: (() -> Void)?
    private(set) var style: CreatePollStyle?

    @discardableResult
    public func set(closeIcon: UIImage) -> Self {
        self.closeIcon = closeIcon
        return self
    }

    @discardableResult
    public func set(createPollIcon: UIImage) -> Self {
        self.createPollIcon = createPollIcon
        return self
    }

    @discardableResult
    public func set(deleteIcon: UIImage) -> Self {
        self.deleteIcon = deleteIcon
        return self
    }

    @discardableResult
    public func setOnCreatePoll(onCreatePoll: @escaping (() -> Void)) -> Self {
        self.onCreatePoll = onCreatePoll
        return self
    }

    @discardableResult
    public func setOnClose(onClose: @escaping (() -> Void)) -> Self {
        self.onClose = onClose
        return self
    }

    @discardableResult
    public func set(style: CreatePollStyle) -> Self {
        self.style = style
        return self
    }
}
