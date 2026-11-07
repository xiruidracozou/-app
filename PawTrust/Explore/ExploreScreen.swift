import SwiftUI
import PawTrustCore

struct ExploreScreen: View {
    @Bindable var model: ExploreModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var peekCore: CGFloat = 200
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let bottomInset = proxy.safeAreaInsets.bottom
            let topInset = proxy.safeAreaInsets.top
            let stops = stops(screen: proxy.size.height, bottom: bottomInset)
            let resting = stops.height(model.state.detent)
            let visual = min(max(resting - dragOffset, stops.peek), stops.large)
            let liftLogo = model.state.detent != .peek || abs(dragOffset) > 16

            ZStack(alignment: .bottom) {
                ExploreMapView(model: model)
                    .ignoresSafeArea()
                    .safeAreaPadding(.bottom, liftLogo ? visual : 0)
                ExploreSheet(
                    model: model,
                    bottomInset: bottomInset,
                    restingHeight: resting,
                    stops: stops,
                    dragOffset: $dragOffset,
                    onSnap: { projected, velocity in
                        snap(projected: projected, velocity: velocity, stops: stops)
                    }
                )
                .frame(height: visual)
            }
            .overlay(alignment: .top) {
                SearchHeader(model: model)
                    .padding(.top, topInset + 6)
            }
            .overlay(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 12) {
                    Spacer(minLength: 96)
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(DemoCopy.mapCaption)
                            .font(.caption)
                            .foregroundStyle(PawTheme.ink)
                            .multilineTextAlignment(.trailing)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(PawTheme.line, lineWidth: 1)
                            )
                        Button(action: { model.recenter() }) {
                            Image(systemName: "location")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(PawTheme.ink)
                                .frame(width: 44, height: 44)
                                .background(Color.white, in: Circle())
                                .overlay(Circle().strokeBorder(PawTheme.line, lineWidth: 1))
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
                        }
                        .accessibilityIdentifier("locate.button")
                        .accessibilityLabel("定位")
                        .accessibilityHint("已有位置时移到你身边。尚未允许时请求定位。已拒绝时回到上海示例区域。")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, visual + 10)
            }
            .background(PawTheme.mapBackdrop)
        }
        .ignoresSafeArea()
        .preferredColorScheme(.light)
        .tint(PawTheme.cobalt)
        .confirmationDialog(
            "在 Apple 地图中查看步行路线？",
            isPresented: Binding(
                get: { model.routePrompt != nil },
                set: { if !$0 { model.routePrompt = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("打开 Apple 地图") { model.openPromptedRoute() }
            Button("取消", role: .cancel) { model.routePrompt = nil }
        } message: {
            Text(model.routePrompt?.boundaryStatement ?? DemoCopy.routeBoundary)
        }
        .onChange(of: model.state.selectedPlaceID) { _, id in
            guard let id, let place = model.place(id) else { return }
            let apply = { model.focus(on: place) }
            if reduceMotion {
                apply()
            } else {
                withAnimation(.easeInOut(duration: 0.45)) { apply() }
            }
        }
    }

    private func stops(screen: CGFloat, bottom: CGFloat) -> SheetStops {
        let cap = dynamicTypeSize.isAccessibilitySize ? 0.52 : 0.34
        let peek = min(peekCore + bottom, screen * cap)
        var medium = min(max(screen * 0.48, 420), screen * 0.60)
        var large = min(screen * 0.74, screen - 110)
        if medium < peek + 100 {
            medium = min(peek + 120, screen * 0.62)
        }
        if large < medium + 80 {
            large = min(max(medium + 80, large), screen - 80)
        }
        return SheetStops(peek: peek, medium: medium, large: large)
    }

    private func snap(projected: CGFloat, velocity: CGFloat, stops: SheetStops) {
        let detent = SheetMotion.resolve(
            projectedHeight: Double(projected),
            velocity: Double(velocity),
            peek: Double(stops.peek),
            medium: Double(stops.medium),
            large: Double(stops.large)
        )
        let apply = {
            dragOffset = 0
            model.setDetent(detent)
        }
        if reduceMotion {
            apply()
        } else {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                apply()
            }
        }
    }
}
