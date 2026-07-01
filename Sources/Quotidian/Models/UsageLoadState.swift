enum UsageLoadState: Equatable {
    case idle
    case loading
    case loaded(UsageSnapshot)
    case stale(UsageSnapshot, reason: String)
    case keychainItemNotFound
    case keychainAccessDenied
    case tokenExpired
    case error(String)
}
