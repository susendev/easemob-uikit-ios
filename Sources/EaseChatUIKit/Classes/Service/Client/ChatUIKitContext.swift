//
//  ChatUIKitContext.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

// 调试使用
/*
import Combine
public enum DictionaryChange<Key: Hashable, Value> {
    case add(key: Key, value: Value)
    case update(key: Key, value: Value)
    case remove(key: Key, removedValue: Value)
    case removeAll
}

public struct ObservableDictionary<Key: Hashable, Value> {
    private let subject = PassthroughSubject<DictionaryChange<Key, Value>, Never>()
    public var publisher: AnyPublisher<DictionaryChange<Key, Value>, Never> {
        subject.eraseToAnyPublisher()
    }
    private var dictionary: [Key: Value]
    public init(_ dictionary: [Key: Value] = [:]) {
        self.dictionary = dictionary
    }
    public subscript(key: Key) -> Value? {
        get {
            dictionary[key]
        }
        set {
            guard let newValue = newValue else {
                if let removedValue = dictionary.removeValue(forKey: key) {
                    subject.send(.remove(key: key, removedValue: removedValue))
                }
                return
            }
            if let _ = dictionary[key] {
                dictionary[key] = newValue
                subject.send(.update(key: key, value: newValue))
            } else {
                dictionary[key] = newValue
                subject.send(.add(key: key, value: newValue))
            }
        }
    }
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        if let removedValue = dictionary.removeValue(forKey: key) {
            subject.send(.remove(key: key, removedValue: removedValue))
            return removedValue
        }
        return nil
    }
    public var values: Dictionary<Key, Value>.Values {
        dictionary.values
    }
    public var keys: Dictionary<Key, Value>.Keys {
        dictionary.keys
    }
    public var count: Int {
        dictionary.count
    }
    public func getValue(forKey key: Key) -> Value? {
        dictionary[key]
    }
    public mutating func removeAll() {
        dictionary.removeAll()
        subject.send(.removeAll)
    }
}
*/
@objc public enum EaseChatUIKitCacheType: UInt {
    case all
    case chat
    case user
    case group
}

@objcMembers public class ChatUIKitContext: NSObject {
    
    @objc public static let shared: ChatUIKitContext? = ChatUIKitContext()

    public var currentUser: ChatUserProfileProtocol? {
        willSet {
            self.chatCache?[self.currentUserId] = newValue
        }
    }
    
    public var currentUserId: String {
        ChatClient.shared().currentUsername ?? ""
    }
    
    /// The cache of user information on the side of the message in the chat page. The key is the user ID and the value is an object that complies with the ``ChatUserProfileProtocol`` protocol.Display the info on chat page.
    public var chatCache: Dictionary<String,ChatUserProfileProtocol>? = Dictionary<String,ChatUserProfileProtocol>()
    
    /// The cache of user information on user. Display the info on contact-list&single-chat-conversation-item&user-profile page .
    public var userCache: Dictionary<String,ChatUserProfileProtocol>? = Dictionary<String,ChatUserProfileProtocol>()
    
    /// The cache of user information on group-conversation-item. The key is the user ID and the value is an object that complies with the ``ChatUserProfileProtocol`` protocol.
    public var groupCache: Dictionary<String,ChatUserProfileProtocol>? = Dictionary<String,ChatUserProfileProtocol>()
    
    public var pinnedCache: Dictionary<String,Bool>? = Dictionary<String,Bool>()
    
    public var userProfileProvider: ChatUserProfileProvider?
    
    public var userProfileProviderOC: ChatUserProfileProviderOC?
    
    public var groupProfileProvider: ChatGroupProfileProvider?
    
    public var groupProfileProviderOC: ChatGroupProfileProviderOC?
    
    /// The first parameter is the group id and the second parameter is the group name.
    public var onGroupNameUpdated: ((String,String) -> Void)?

    /*   
    private var cancellables = Set<AnyCancellable>()

    public var chatCache: ObservableDictionary<String,ChatUserProfileProtocol>? = ObservableDictionary<String,ChatUserProfileProtocol>()
    
    public var userCache: ObservableDictionary<String,ChatUserProfileProtocol>? = ObservableDictionary<String,ChatUserProfileProtocol>()
    
    public var groupCache: ObservableDictionary<String,ChatUserProfileProtocol>? = ObservableDictionary<String,ChatUserProfileProtocol>()

    public override init() {
        super.init()
        if #available(iOS 14.0, *) {
            userCache?.publisher
                .sink { change in
                    print("--- ObservableDictionary 监听到变化 ---")
                    switch change {
                    case .add(let key, let value):
                        print("✅ userCache 新增用户: Key = \(key), Value = \(value.nickname) | \(value.avatarURL)")
                    case .update(let key, let value):
                        print("🔄 userCache 更新用户: Key = \(key), Value = \(value.nickname) | \(value.avatarURL)")
                    case .remove(let key, let value):
                        print("❌ userCache 移除用户: Key = \(key),  Value = \(value.nickname) | \(value.avatarURL)")
                    case .removeAll:
                        print("❌ userCache 移除用户: removeAll")
                    }

                }
                .store(in: &cancellables)
            chatCache?.publisher
                .sink { change in
                    print("--- ObservableDictionary 监听到变化 ---")
                    switch change {
                    case .add(let key, let value):
                        print("✅ chatCache 新增用户: Key = \(key), Value = \(value.nickname) | \(value.avatarURL)")
                    case .update(let key, let value):
                        print("🔄 chatCache 更新用户: Key = \(key), Value = \(value.nickname) | \(value.avatarURL)")
                    case .remove(let key, let value):
                        print("❌ chatCache 移除用户: Key = \(key),  Value = \(value.nickname) | \(value.avatarURL)")
                    case .removeAll:
                        print("❌ chatCache 移除用户: removeAll")
                    }

                }
                .store(in: &cancellables)
        } else {
            // Fallback on earlier versions
        }

    }
    */
    
    /// Clean the cache of ``EaseChatUIKitCacheType`` type
    /// - Parameter type: ``EaseChatUIKitCacheType``
    @objc(cleanCacheWithType:)
    public func cleanCache(type: EaseChatUIKitCacheType) {
        switch type {
        case .all:
            self.chatCache?.removeAll()
            self.userCache?.removeAll()
            self.groupCache?.removeAll()
        case .chat://不需要对外暴露
            self.chatCache?.removeAll()
        case .user: self.userCache?.removeAll()
        case .group: self.groupCache?.removeAll()
        default: break
        }
    }
    
    
    /// Update the cache of ``EaseChatUIKitCacheType`` type
    /// - Parameters:
    ///   - type: ``EaseChatUIKitCacheType``
    ///   - profile: The object conform to ``ChatUserProfileProtocol``.
    @objc(updateCacheWithType:profile:)
    public func updateCache(type: EaseChatUIKitCacheType,profile: ChatUserProfileProtocol) {
        switch type {
        case .chat:
            self.chatCache?[profile.id] = profile
        case .user:
            self.userCache?[profile.id] = profile
        case .group:
            self.groupCache?[profile.id] = profile
        default:
            break
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: cache_update_notification), object: nil, userInfo: nil)
    }
    
    public func updateCaches(type: EaseChatUIKitCacheType,profiles: [ChatUserProfileProtocol]) {
        switch type {
        case .chat:
            profiles.forEach { profile in
                self.chatCache?[profile.id] = profile
            }
        case .user:
            profiles.forEach { profile in
                self.userCache?[profile.id] = profile
            }
        case .group:
            profiles.forEach { profile in
                self.groupCache?[profile.id] = profile
            }
        default:
            break
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: cache_update_notification), object: nil, userInfo: nil)
    }
}
