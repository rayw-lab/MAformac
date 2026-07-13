import Foundation

// MARK: - Opaque route identifiers

/// W6 route wire 用 `turn_id` + `trace_id` 标识每一次 route 决策；
/// W7 dialogue 用 `session_ref` + `generation_ref` + `group_ordinal` 标识 group。
///
/// 两套标识体系在 D1 wire 阶段必须建立 correlation，本 P2#4 提供 typed 骨架，
/// 不引入 W6 / W7 wire 层依赖（W6 Swift 类型不在本 change 可写面之内）。
public struct RouteTurnIdentifier: Codable, Equatable, Hashable, Sendable {
    public let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct RouteTraceIdentifier: Codable, Equatable, Hashable, Sendable {
    public let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - Correlation payload from W6 route

/// W6 route 侧提供的 correlation 载体。opaque String 字段，避免 import W6 types。
///
/// - `routeTurnID` / `routeTraceID`：源自 W6 `RouteResult.turn_id` / `trace_id`
///   （见 `Core/Contracts/RouteResult.swift`；本 change 不 import 该类型）。
/// - `traceDigestRef`：`RouteResult.trace_digest` 的 opaque 引用；本 change 不定义算法。
/// - `actionCandidateRef`：`RouteResult.action_candidate` 的 opaque 引用；nil 表示
///   route outcome 为 clarify/reject/fallback（没有 candidate）。
public struct DialogueRouteAttribution: Codable, Equatable, Sendable {
    public let routeTurnID: RouteTurnIdentifier
    public let routeTraceID: RouteTraceIdentifier
    public let traceDigestRef: String?
    public let actionCandidateRef: String?
    public let schemaVersion: DialogueStateSchemaVersion

    public init(
        routeTurnID: RouteTurnIdentifier,
        routeTraceID: RouteTraceIdentifier,
        traceDigestRef: String? = nil,
        actionCandidateRef: String? = nil,
        schemaVersion: DialogueStateSchemaVersion
    ) {
        self.routeTurnID = routeTurnID
        self.routeTraceID = routeTraceID
        self.traceDigestRef = traceDigestRef
        self.actionCandidateRef = actionCandidateRef
        self.schemaVersion = schemaVersion
    }
}

// MARK: - Correlation record

/// 完整 correlation：W6 route identity ↔ W7 dialogue group identity。
///
/// 本 typed 是 D1 wire 阶段的接线契约骨架；本 change 不实现 W6→W7 或 W7→W6 的
/// 具体映射函数——只承载 shape，为将来两 wire 层落地时提供 versioned edge。
public struct RouteToDialogueCorrelation: Codable, Equatable, Sendable {
    public let route: DialogueRouteAttribution
    public let dialogueGroupRef: DialogueSourceGroupRef
    public let schemaVersion: DialogueStateSchemaVersion

    public init(
        route: DialogueRouteAttribution,
        dialogueGroupRef: DialogueSourceGroupRef,
        schemaVersion: DialogueStateSchemaVersion
    ) {
        self.route = route
        self.dialogueGroupRef = dialogueGroupRef
        self.schemaVersion = schemaVersion
    }
}

// MARK: - Errors

public enum DialogueRouteCorrelationError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(rawValue: String)
    case missingRouteTurnID
    case missingRouteTraceID
    case routeAndCorrelationVersionMismatch(routeRawValue: String, correlationRawValue: String)
    case dialogueGroupRefMissingIdentity(field: String)
}

// MARK: - Validator

public enum DialogueRouteCorrelationValidator {
    public static func validate(
        _ correlation: RouteToDialogueCorrelation
    ) -> Result<RouteToDialogueCorrelation, DialogueRouteCorrelationError> {
        guard correlation.schemaVersion.isSupported else {
            return .failure(.unsupportedSchemaVersion(rawValue: correlation.schemaVersion.rawValue))
        }
        guard correlation.route.schemaVersion.isSupported else {
            return .failure(.unsupportedSchemaVersion(rawValue: correlation.route.schemaVersion.rawValue))
        }
        if correlation.route.schemaVersion.rawValue != correlation.schemaVersion.rawValue {
            return .failure(.routeAndCorrelationVersionMismatch(
                routeRawValue: correlation.route.schemaVersion.rawValue,
                correlationRawValue: correlation.schemaVersion.rawValue
            ))
        }
        if correlation.route.routeTurnID.rawValue.isEmpty {
            return .failure(.missingRouteTurnID)
        }
        if correlation.route.routeTraceID.rawValue.isEmpty {
            return .failure(.missingRouteTraceID)
        }
        if correlation.dialogueGroupRef.sessionRef.isEmpty {
            return .failure(.dialogueGroupRefMissingIdentity(field: "sessionRef"))
        }
        if correlation.dialogueGroupRef.generationRef.isEmpty {
            return .failure(.dialogueGroupRefMissingIdentity(field: "generationRef"))
        }
        return .success(correlation)
    }
}

// MARK: - Wiring residual marker

/// D1 wire 层责任 marker（uninhabited）——W6→W7 的实际调用点由 D1 阶段签 RISK-ACK 后落地，
/// 本 change 不承担消费。
public enum RouteToDialogueWireResponsibilityMarker: Sendable {
    // no cases — real wiring belongs to D1 (RISK-ACK-D1 required).
}
