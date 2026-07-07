import SwiftUI
import Vortex

enum ContextCapsuleRoute: String {
    case cLite
    case videoLoop
}

struct ContextCapsuleView: View {
    var theme: PresentationTheme
    var context: DemoContext
    var route: ContextCapsuleRoute = .cLite

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rainSystem = VortexSystem.rain.makeUniqueCopy()
    @State private var smokeSystem = VortexSystem.smoke.makeUniqueCopy()

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }
    private var isRainy: Bool { context.environment.weather.contains("雨") }
    private var isNight: Bool { context.environment.timePeriod.contains("夜") }
    private var isMoving: Bool { context.vehicle.speed > 0 && context.vehicle.gear != "P" }
    private var speedFactor: Double { min(1, max(0, Double(context.vehicle.speed) / 80.0)) }

    var body: some View {
        Group {
            if PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: reduceMotion) {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    capsuleContent(phase: timeline.date.timeIntervalSinceReferenceDate)
                }
            } else {
                capsuleContent(phase: 0)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private func capsuleContent(phase: TimeInterval) -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                ZStack {
                    baseDioramaLayer(phase: phase)
                    sceneTint
                    headlightLayer(size: size, phase: phase)
                    roadMotionLayer(size: size, phase: phase)
                    weatherLayer(size: size, phase: phase)
                    exhaustLayer(size: size, phase: phase)
                    glassHighlight(size: size, phase: phase)
                }
                .padding(0.5)
                .compositingGroup()
                .clipShape(Capsule(), style: FillStyle(antialiased: true))
                .contentTransition(.opacity)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.42), value: sceneKey)

                capsuleChrome
            }
            .compositingGroup()
            .clipShape(Capsule(), style: FillStyle(antialiased: true))
            .shadow(color: palette.softShadow.opacity(theme == .ivory ? 0.12 : 0.40), radius: 14, y: 8)
        }
    }

    private var capsuleChrome: some View {
        Capsule()
            .fill(Color.clear)
            .glassEffect(.regular, in: Capsule())
            .opacity(theme == .ivory ? 0.34 : 0.55)
            .overlay {
                Capsule().strokeBorder(Color.white.opacity(theme == .ivory ? 0.16 : 0.12), lineWidth: 0.8)
            }
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private func baseDioramaLayer(phase: TimeInterval) -> some View {
        switch route {
        case .cLite:
            Image("ContextCapsule")
                .resizable()
                .scaledToFill()
                .modifier(BaseDioramaMotion(
                    phase: phase,
                    route: route,
                    isMoving: isMoving,
                    isRainy: isRainy,
                    isNight: isNight,
                    speedFactor: speedFactor,
                    theme: theme
                ))
        case .videoLoop:
            if reduceMotion {
                Image("ContextCapsule")
                    .resizable()
                    .scaledToFill()
                    .modifier(BaseDioramaMotion(
                        phase: phase,
                        route: route,
                        isMoving: isMoving,
                        isRainy: isRainy,
                        isNight: isNight,
                        speedFactor: speedFactor,
                        theme: theme
                    ))
            } else {
                ContextCapsuleVideoLoopView()
                    .modifier(BaseDioramaMotion(
                        phase: phase,
                        route: route,
                        isMoving: isMoving,
                        isRainy: isRainy,
                        isNight: isNight,
                        speedFactor: speedFactor,
                        theme: theme
                    ))
            }
        }
    }

    private struct BaseDioramaMotion: ViewModifier {
        let phase: TimeInterval
        let route: ContextCapsuleRoute
        let isMoving: Bool
        let isRainy: Bool
        let isNight: Bool
        let speedFactor: Double
        let theme: PresentationTheme

        func body(content: Content) -> some View {
            content
            .scaleEffect(x: 1.03, y: 1.08, anchor: .center)
            .offset(
                x: horizontalOffset,
                y: isRainy ? 0.2 : 0
            )
            .saturation(isRainy ? 0.82 : (theme == .ivory ? 1.10 : 0.76))
            .brightness(isNight ? -0.22 : (theme == .ivory ? 0.02 : -0.14))
        }

        private var horizontalOffset: CGFloat {
            if route == .videoLoop {
                return isMoving ? CGFloat(sin(phase * 0.28) * 1.4 * speedFactor) : 0
            }
            return isMoving ? CGFloat(sin(phase * 0.45) * 3.0 * speedFactor) : CGFloat(sin(phase * 0.16) * 0.9)
        }
    }

    private var sceneTint: some View {
        ZStack {
            if isNight {
                LinearGradient(
                    colors: [
                        DesignTokens.bgDeepest.opacity(0.46),
                        DesignTokens.glowViolet.opacity(0.26),
                        DesignTokens.semanticCool.opacity(0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottomTrailing
                )
            }

            if isRainy {
                LinearGradient(
                    colors: [
                        DesignTokens.semanticCool.opacity(theme == .ivory ? 0.18 : 0.28),
                        DesignTokens.inkDim.opacity(theme == .ivory ? 0.10 : 0.22)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func weatherLayer(size: CGSize, phase: TimeInterval) -> some View {
        if isRainy {
            if reduceMotion {
                rainCanvas(size: size, phase: phase)
            } else {
                VortexView(rainSystem) {
                    Capsule()
                        .fill(Color.white.opacity(theme == .ivory ? 0.62 : 0.78))
                        .frame(width: 1.6, height: 13)
                        .tag("circle")
                }
                .blendMode(.plusLighter)
                .opacity(theme == .ivory ? 0.56 : 0.82)
                .allowsHitTesting(false)
            }
        } else if isNight {
            starCanvas(size: size, phase: phase)
        }
    }

    @ViewBuilder
    private func exhaustLayer(size: CGSize, phase: TimeInterval) -> some View {
        if isMoving || context.vehicle.gear == "P" {
            if reduceMotion {
                smokeCanvas(size: size, phase: phase)
            } else {
                VortexView(smokeSystem) {
                    Circle()
                        .fill(Color.white.opacity(isNight ? 0.35 : 0.46))
                        .blur(radius: 1.6)
                        .frame(width: 11)
                        .tag("circle")
                }
                .frame(width: size.width * 0.30, height: size.height * 0.34)
                .offset(x: size.width * 0.30, y: size.height * 0.16)
                .opacity(isRainy ? 0.32 : 0.52)
                .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    private func headlightLayer(size: CGSize, phase: TimeInterval) -> some View {
        if isNight || isRainy {
            let pulse = 0.72 + sin(phase * 1.2) * 0.08
            Path { path in
                path.move(to: CGPoint(x: size.width * 0.62, y: size.height * 0.61))
                path.addLine(to: CGPoint(x: size.width * 0.92, y: size.height * 0.48))
                path.addLine(to: CGPoint(x: size.width * 0.96, y: size.height * 0.70))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        DesignTokens.semanticWarmBright.opacity(0.36 * pulse),
                        Color.white.opacity(0.20 * pulse),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .blur(radius: 6)
            .blendMode(.plusLighter)
        }
    }

    @ViewBuilder
    private func roadMotionLayer(size: CGSize, phase: TimeInterval) -> some View {
        if isMoving {
            Canvas { context, size in
                let base = phase * (70 + speedFactor * 110)
                for index in 0..<13 {
                    let y = size.height * (0.68 + Double(index % 4) * 0.045)
                    let x = (base + Double(index * 31)).truncatingRemainder(dividingBy: Double(size.width) + 80) - 40
                    var streak = Path()
                    streak.move(to: CGPoint(x: x, y: y))
                    streak.addLine(to: CGPoint(x: x + 34 + speedFactor * 26, y: y - 3))
                    context.stroke(
                        streak,
                        with: .color(Color.white.opacity(0.10 + speedFactor * 0.14)),
                        style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
                    )
                }
            }
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
        }
    }

    private func rainCanvas(size: CGSize, phase: TimeInterval) -> some View {
        Canvas { context, size in
            for index in 0..<32 {
                let x = (Double(index * 23) + phase * 26).truncatingRemainder(dividingBy: Double(size.width) + 30) - 15
                let y = (Double(index * 17) + phase * 78).truncatingRemainder(dividingBy: Double(size.height) + 30) - 15
                var drop = Path()
                drop.move(to: CGPoint(x: x, y: y))
                drop.addLine(to: CGPoint(x: x + 8, y: y + 22))
                context.stroke(drop, with: .color(Color.white.opacity(0.42)), style: StrokeStyle(lineWidth: 1, lineCap: .round))
            }
        }
        .allowsHitTesting(false)
    }

    private func smokeCanvas(size: CGSize, phase: TimeInterval) -> some View {
        Canvas { context, size in
            for index in 0..<5 {
                let t = (phase * 0.22 + Double(index) * 0.18).truncatingRemainder(dividingBy: 1)
                let center = CGPoint(
                    x: size.width * (0.72 + t * 0.18),
                    y: size.height * (0.62 - t * 0.10 + sin(Double(index) + phase) * 0.015)
                )
                let radius = size.height * (0.06 + t * 0.07)
                context.fill(Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius * 0.55, width: radius * 1.8, height: radius)),
                             with: .color(Color.white.opacity(0.18 * (1 - t))))
            }
        }
        .blur(radius: 3)
        .allowsHitTesting(false)
    }

    private func starCanvas(size: CGSize, phase: TimeInterval) -> some View {
        Canvas { context, size in
            for index in 0..<18 {
                let x = size.width * CGFloat((Double(index * 37).truncatingRemainder(dividingBy: 100)) / 100.0)
                let y = size.height * CGFloat(0.10 + (Double(index * 19).truncatingRemainder(dividingBy: 36)) / 100.0)
                let opacity = 0.24 + 0.20 * sin(phase * 0.9 + Double(index))
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 2.2, height: 2.2)), with: .color(Color.white.opacity(opacity)))
            }
        }
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }

    private func glassHighlight(size: CGSize, phase: TimeInterval) -> some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .fill(Color.white.opacity(theme == .ivory ? 0.42 : 0.22))
                .frame(width: size.height * 0.34, height: size.height * 0.20)
                .blur(radius: 4)
                .offset(x: size.width * 0.045 + CGFloat(sin(phase * 0.25) * 2), y: size.height * 0.05)
        }
        .allowsHitTesting(false)
    }

    private var sceneKey: String {
        "\(context.vehicle.speed)-\(context.vehicle.gear)-\(context.environment.weather)-\(context.environment.timePeriod)-\(theme.rawValue)"
    }

    private var accessibilityLabel: String {
        "环境胶囊，\(context.environment.timePeriod)，\(context.environment.weather)，\(context.vehicle.speed)公里每小时，\(context.vehicle.gear)挡"
    }
}
