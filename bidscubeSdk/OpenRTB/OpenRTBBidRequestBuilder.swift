import Foundation

/// Placeholder for future OpenRTB 2.6 bid-request POST support.
/// Production flow still uses legacy GET requests via `URLBuilder`.
enum OpenRTBBidRequestBuilder {
    // TODO: Build OpenRTB 2.6 JSON bid request body.
    // TODO: Wire POST auction endpoint when product enables full OpenRTB client mode.
    // TODO: Keep separate from legacy GET `m=xml` / `c=v` flow until explicitly requested.
}
