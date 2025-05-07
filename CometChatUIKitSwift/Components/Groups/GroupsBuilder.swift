//
//  GroupsBuilder.swift

//
//  Created by Pushpsen Airekar on 18/11/22.
//

import CometChatSDK
import Foundation

enum GroupsBuilderResult {
    case success([Group])
    case failure(CometChatException)
}

public class GroupsBuilder {
    public static func getDefaultRequestBuilder() -> CometChatSDK.GroupsRequest.GroupsRequestBuilder {
        CometChatSDK.GroupsRequest.GroupsRequestBuilder(limit: 30)
    }

    static func getSearchBuilder(searchText: String, groupRequestBuilder: CometChatSDK.GroupsRequest.GroupsRequestBuilder = getDefaultRequestBuilder()) -> CometChatSDK.GroupsRequest.GroupsRequestBuilder {
        groupRequestBuilder.set(searchKeyword: searchText)
    }

    static func getfilteredGroups(filterGroupRequest: GroupsRequest, completion: @escaping (GroupsBuilderResult) -> Void) {
        filterGroupRequest.fetchNext { groups in
            completion(.success(groups))
        } onError: { error in
            guard let error else { return }
            completion(.failure(error))
        }
    }

    static func fetchGroups(groupRequest: GroupsRequest, completion: @escaping (GroupsBuilderResult) -> Void) {
        groupRequest.fetchNext { fetchedGroups in
            completion(.success(fetchedGroups))
        } onError: { error in
            guard let error else { return }
            completion(.failure(error))
        }
    }
}
