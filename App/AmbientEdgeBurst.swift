import SwiftUI

struct AmbientBurstTrigger: Identifiable, Equatable {
    let id: UUID
    let colorName: String
    let startedAt: Date

    init(id: UUID = UUID(), colorName: String, startedAt: Date = Date()) {
        self.id = id
        self.colorName = AmbientBurstColorMapper.normalizedColorName(for: colorName)
        self.startedAt = startedAt
    }
}

struct AmbientEdgeBurst: View {
    let trigger: AmbientBurstTrigger
    var theme: PresentationTheme
    var onFinished: (UUID) -> Void

    private var gradient: [Color] {
        let mapped = DesignTokens.ambientGradient(named: trigger.colorName)
        let white = DesignTokens.ambientColor(named: "白色")
        switch trigger.colorName {
        case "紫色":
            return [
                DesignTokens.ambientColor(named: "紫色"),
                DesignTokens.ambientColor(named: "浅蓝紫色"),
                DesignTokens.glowViolet,
                mapped.dropFirst().first ?? DesignTokens.ambientColor(named: "黄色"),
                white
            ]
        case "浅蓝紫色":
            return [
                DesignTokens.ambientColor(named: "浅蓝紫色"),
                DesignTokens.ambientColor(named: "紫色"),
                DesignTokens.ambientColor(named: "蓝色"),
                white
            ]
        default:
            return mapped + [white]
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                TimedAmbientEdgeGlow(trigger: trigger, colors: gradient, theme: theme)

                PhaseAnimator(AmbientBurstPhase.allCases, trigger: trigger.id) { phase in
                    edgeGlow(size: size, phase: phase)
                } animation: { phase in
                    phase.animation
                }

                AmbientParticleCanvas(trigger: trigger, colors: gradient, theme: theme)
            }
            .frame(width: size.width, height: size.height)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .task(id: trigger.id) {
                try? await Task.sleep(nanoseconds: UInt64(DesignTokens.ambientBurstDuration * 1_000_000_000))
                await MainActor.run { onFinished(trigger.id) }
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func edgeGlow(size: CGSize, phase: AmbientBurstPhase) -> some View {
        let primary = gradient.first ?? DesignTokens.glowViolet
        let secondary = gradient.dropFirst().first ?? DesignTokens.semanticWarmBright
        let width = min(size.width, size.height)
        let strip = max(44, width * (theme == .ivory ? 0.13 : 0.16))
        let ringInset = max(6, width * 0.018)
        let ringCorner = min(width * 0.105, 72)
        let energy = theme == .ivory ? 0.78 : 1.0

        ZStack {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [primary.opacity(phase.stripOpacity * energy), secondary.opacity(phase.stripOpacity * 0.50 * energy), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: strip)
                Spacer(minLength: 0)
                LinearGradient(
                    colors: [.clear, secondary.opacity(phase.stripOpacity * 0.42 * energy), primary.opacity(phase.stripOpacity * 0.78 * energy)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: strip * 0.92)
            }

            HStack(spacing: 0) {
                LinearGradient(
                    colors: [primary.opacity(phase.stripOpacity * energy), secondary.opacity(phase.stripOpacity * 0.62 * energy), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: strip)
                Spacer(minLength: 0)
                LinearGradient(
                    colors: [.clear, secondary.opacity(phase.stripOpacity * 0.62 * energy), primary.opacity(phase.stripOpacity * energy)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: strip)
            }

            RoundedRectangle(cornerRadius: ringCorner, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: gradient.map { $0.opacity(phase.ringOpacity * energy) },
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    lineWidth: phase.ringWidth
                )
                .padding(ringInset)
                .shadow(color: primary.opacity(phase.ringOpacity * 0.92 * energy), radius: phase.shadowRadius, y: 0)
                .shadow(color: secondary.opacity(phase.ringOpacity * 0.60 * energy), radius: phase.shadowRadius * 1.55, y: 0)

            RoundedRectangle(cornerRadius: ringCorner + 12, style: .continuous)
                .strokeBorder(primary.opacity(phase.ringOpacity * 0.28 * energy), lineWidth: 1)
                .padding(ringInset + 12)
                .blur(radius: 1.2)

            RadialGradient(
                colors: [
                    secondary.opacity(theme == .ivory ? phase.centerMist * 0.18 : phase.centerMist * 0.26),
                    primary.opacity(theme == .ivory ? phase.centerMist * 0.10 : phase.centerMist * 0.16),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: width * 0.58
            )
            .blendMode(.plusLighter)
        }
        .opacity(phase.overallOpacity)
    }
}

private enum AmbientBurstPhase: CaseIterable, Equatable {
    case flash
    case bloom
    case linger
    case fade

    var animation: Animation {
        switch self {
        case .flash:
            .easeOut(duration: 0.14)
        case .bloom:
            .spring(duration: 0.48, bounce: 0.22)
        case .linger:
            .easeInOut(duration: 2.15)
        case .fade:
            .easeOut(duration: 2.20)
        }
    }

    var stripOpacity: Double {
        switch self {
        case .flash: return 0.86
        case .bloom: return 0.74
        case .linger: return 0.58
        case .fade: return 0.0
        }
    }

    var ringOpacity: Double {
        switch self {
        case .flash: return 1.0
        case .bloom: return 0.88
        case .linger: return 0.74
        case .fade: return 0.0
        }
    }

    var ringWidth: CGFloat {
        switch self {
        case .flash: return 7
        case .bloom: return 5.5
        case .linger: return 3.5
        case .fade: return 1
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .flash: return 34
        case .bloom: return 44
        case .linger: return 28
        case .fade: return 0
        }
    }

    var centerMist: Double {
        switch self {
        case .flash: return 0.55
        case .bloom: return 0.42
        case .linger: return 0.26
        case .fade: return 0.0
        }
    }

    var overallOpacity: Double {
        switch self {
        case .flash, .bloom, .linger: return 1
        case .fade: return 0
        }
    }
}

private struct TimedAmbientEdgeGlow: View {
    let trigger: AmbientBurstTrigger
    let colors: [Color]
    var theme: PresentationTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = max(0, timeline.date.timeIntervalSince(trigger.startedAt))
            let progress = min(1, elapsed / DesignTokens.ambientBurstDuration)
            let rampIn = min(1, progress / 0.08)
            let fadeOut = pow(max(0, 1 - progress), 0.28)
            GeometryReader { proxy in
                timedGlow(size: proxy.size, energy: rampIn * fadeOut)
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func timedGlow(size: CGSize, energy: Double) -> some View {
        let primary = colors.first ?? DesignTokens.glowViolet
        let secondary = colors.dropFirst().first ?? DesignTokens.semanticWarmBright
        let white = DesignTokens.ambientColor(named: "白色")
        let minSide = min(size.width, size.height)
        let strip = max(82, minSide * 0.24)
        let ringInset = max(4, minSide * 0.012)
        let ringCorner = min(minSide * 0.115, 78)
        let base = theme == .ivory ? 0.94 : 1.12

        ZStack {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        primary.opacity(0.95 * energy * base),
                        primary.opacity(0.38 * energy * base),
                        secondary.opacity(0.22 * energy * base),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: strip)
                Spacer(minLength: 0)
                LinearGradient(
                    colors: [
                        .clear,
                        secondary.opacity(0.18 * energy * base),
                        primary.opacity(0.44 * energy * base),
                        primary.opacity(0.92 * energy * base)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: strip)
            }

            HStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        primary.opacity(0.98 * energy * base),
                        primary.opacity(0.48 * energy * base),
                        secondary.opacity(0.18 * energy * base),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: strip)
                Spacer(minLength: 0)
                LinearGradient(
                    colors: [
                        .clear,
                        secondary.opacity(0.18 * energy * base),
                        primary.opacity(0.48 * energy * base),
                        primary.opacity(0.98 * energy * base)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: strip)
            }

            RoundedRectangle(cornerRadius: ringCorner, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [
                        white.opacity(0.82 * energy),
                        primary.opacity(1.00 * energy * base),
                        secondary.opacity(0.62 * energy * base),
                        primary.opacity(1.00 * energy * base),
                        white.opacity(0.70 * energy)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 7
                )
                .padding(ringInset)
                .shadow(color: primary.opacity(0.96 * energy * base), radius: 34)
                .shadow(color: primary.opacity(0.54 * energy * base), radius: 64)

            RoundedRectangle(cornerRadius: ringCorner + 18, style: .continuous)
                .strokeBorder(primary.opacity(0.45 * energy * base), lineWidth: 2)
                .padding(ringInset + 16)
                .blur(radius: 1.8)
        }
        .opacity(energy)
        .blendMode(theme == .deepSpace ? .plusLighter : .normal)
    }
}

private struct AmbientParticleCanvas: View {
    let trigger: AmbientBurstTrigger
    let colors: [Color]
    var theme: PresentationTheme

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 45.0)) { timeline in
            Canvas { context, size in
                let elapsed = max(0, timeline.date.timeIntervalSince(trigger.startedAt))
                let progress = min(1, elapsed / DesignTokens.ambientBurstDuration)
                draw(in: &context, size: size, progress: progress)
            }
            .blendMode(theme == .deepSpace ? .plusLighter : .normal)
        }
        .allowsHitTesting(false)
    }

    private func draw(in context: inout GraphicsContext, size: CGSize, progress: Double) {
        guard size.width > 1, size.height > 1, progress < 1 else { return }

        context.blendMode = theme == .deepSpace ? .plusLighter : .normal
        let minSide = min(size.width, size.height)
        let edgeDepth = max(50, minSide * (theme == .ivory ? 0.20 : 0.24))
        let count = theme == .ivory ? 250 : 310
        let seed = Double(abs(trigger.id.uuidString.hashValue % 10_000))
        let rampIn = min(1, progress / 0.10)
        let fadeOut = pow(max(0, 1 - progress), theme == .ivory ? 1.35 : 1.12)
        let energy = rampIn * fadeOut

        for index in 0..<count {
            let base = seed + Double(index) * 17.173
            let side = index % 4
            let u = random(base + 0.11)
            let speed = 0.42 + random(base + 0.29) * 0.88
            let drift = edgeDepth * (0.20 + speed * progress)
            let tangential = sin(progress * (5.2 + random(base + 0.41) * 8.0) + base) * (6 + random(base + 0.53) * 18)
            let edgeJitter = random(base + 0.67) * 20
            let color = colors[index % max(1, colors.count)]
            let opacity = energy * (0.28 + random(base + 0.79) * 0.72)
            let radius = max(1.2, minSide * (0.0023 + random(base + 0.91) * 0.0050))
            let lineLength = edgeDepth * (0.24 + random(base + 1.13) * 0.58) * (1 - progress * 0.24)

            let particle = point(side: side,
                                 u: u,
                                 size: size,
                                 drift: drift,
                                 tangential: tangential,
                                 edgeJitter: edgeJitter)

            if index.isMultiple(of: 2) {
                let edge = edgePoint(side: side, u: u, size: size, tangential: tangential * 0.32)
                let target = lineTarget(from: edge, side: side, length: lineLength)
                var ray = Path()
                ray.move(to: edge)
                ray.addLine(to: target)
                context.stroke(
                    ray,
                    with: .color(color.opacity(opacity * 0.50)),
                    style: StrokeStyle(lineWidth: max(0.45, radius * 0.38), lineCap: .round)
                )
            }

            if index.isMultiple(of: 5) {
                drawSparkle(at: particle, radius: radius * 2.05, color: color, opacity: opacity, context: &context)
            } else {
                let rect = CGRect(x: particle.x - radius, y: particle.y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(color.opacity(opacity)))
            }
        }
    }

    private func point(side: Int, u: Double, size: CGSize, drift: CGFloat, tangential: CGFloat, edgeJitter: CGFloat) -> CGPoint {
        switch side {
        case 0:
            CGPoint(x: size.width * u + tangential, y: edgeJitter + drift)
        case 1:
            CGPoint(x: size.width - edgeJitter - drift, y: size.height * u + tangential)
        case 2:
            CGPoint(x: size.width * (1 - u) + tangential, y: size.height - edgeJitter - drift)
        default:
            CGPoint(x: edgeJitter + drift, y: size.height * (1 - u) + tangential)
        }
    }

    private func edgePoint(side: Int, u: Double, size: CGSize, tangential: CGFloat) -> CGPoint {
        switch side {
        case 0:
            CGPoint(x: size.width * u + tangential, y: 0)
        case 1:
            CGPoint(x: size.width, y: size.height * u + tangential)
        case 2:
            CGPoint(x: size.width * (1 - u) + tangential, y: size.height)
        default:
            CGPoint(x: 0, y: size.height * (1 - u) + tangential)
        }
    }

    private func lineTarget(from point: CGPoint, side: Int, length: CGFloat) -> CGPoint {
        switch side {
        case 0: return CGPoint(x: point.x, y: point.y + length)
        case 1: return CGPoint(x: point.x - length, y: point.y)
        case 2: return CGPoint(x: point.x, y: point.y - length)
        default: return CGPoint(x: point.x + length, y: point.y)
        }
    }

    private func drawSparkle(at point: CGPoint, radius: CGFloat, color: Color, opacity: Double, context: inout GraphicsContext) {
        var vertical = Path()
        vertical.move(to: CGPoint(x: point.x, y: point.y - radius))
        vertical.addLine(to: CGPoint(x: point.x, y: point.y + radius))

        var horizontal = Path()
        horizontal.move(to: CGPoint(x: point.x - radius, y: point.y))
        horizontal.addLine(to: CGPoint(x: point.x + radius, y: point.y))

        let style = StrokeStyle(lineWidth: max(0.45, radius * 0.16), lineCap: .round)
        context.stroke(vertical, with: .color(color.opacity(opacity)), style: style)
        context.stroke(horizontal, with: .color(color.opacity(opacity * 0.78)), style: style)
    }

    private func random(_ seed: Double) -> Double {
        let value = sin(seed * 12.9898) * 43_758.5453
        return value - floor(value)
    }
}
