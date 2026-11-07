import SwiftUI
import PawTrustCore

struct SheetStops: Equatable {
    var peek: CGFloat
    var medium: CGFloat
    var large: CGFloat

    func height(_ detent: SheetDetent) -> CGFloat {
        switch detent {
        case .peek: peek
        case .medium: medium
        case .large: large
        }
    }
}

struct ExploreSheet: View {
    @Bindable var model: ExploreModel
    var bottomInset: CGFloat
    var restingHeight: CGFloat
    var stops: SheetStops
    @Binding var dragOffset: CGFloat
    var onSnap: (CGFloat, CGFloat) -> Void

    private var showDetail: Bool {
        model.selectedPlace != nil && model.state.detent != .peek
    }

    var body: some View {
        VStack(spacing: 0) {
            dragHandle
            if let place = model.selectedPlace, showDetail {
                detail(place)
            } else {
                peek
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            if showDetail {
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: 28, bottomLeading: 0, bottomTrailing: 0, topTrailing: 28),
                    style: .continuous
                )
                .fill(PawTheme.card)
                .shadow(color: .black.opacity(0.12), radius: 18, y: -6)
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    private var dragHandle: some View {
        Capsule()
            .fill(showDetail ? Color.black.opacity(0.16) : Color.white)
            .frame(width: 36, height: 5)
            .shadow(color: .black.opacity(showDetail ? 0 : 0.12), radius: 2, y: 1)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
            .gesture(drag)
            .accessibilityLabel("详情高度")
            .accessibilityValue(model.state.detent.title)
            .accessibilityHint("上下轻扫可调整高度。收起会取消选择。")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    model.stepDetent(up: true)
                case .decrement:
                    model.stepDetent(up: false)
                @unknown default:
                    break
                }
            }
            .accessibilityIdentifier("sheet.handle")
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 14, coordinateSpace: .global)
            .onChanged { value in
                let proposed = restingHeight - value.translation.height
                let clamped = min(max(proposed, stops.peek), stops.large)
                dragOffset = restingHeight - clamped
            }
            .onEnded { value in
                onSnap(restingHeight - value.translation.height, value.velocity.height)
            }
    }

    private var peek: some View {
        VStack(spacing: 6) {
            peekCard
            brandBar
            Color.clear
                .frame(height: 16)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, bottomInset)
        .contentShape(Rectangle())
        .gesture(drag)
    }

    @ViewBuilder
    private var peekCard: some View {
        let summary = model.summary
        if let id = summary.suggestedPlaceID, let place = model.place(id) {
            Button(action: { model.performPeekAction() }) {
                HStack(spacing: 12) {
                    PlacePhoto(place: place, cornerRadius: 14)
                        .frame(width: 64, height: 64)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(summary.title)
                            .font(.headline)
                            .foregroundStyle(PawTheme.ink)
                        Text(summary.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(PawTheme.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(PawTheme.secondary)
                        .frame(width: 44, height: 44)
                        .accessibilityHidden(true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
            }
            .buttonStyle(.plain)
            .pawCard(radius: 22)
            .accessibilityIdentifier("peek.card")
            .accessibilityLabel("\(summary.title)，\(summary.subtitle)")
            .accessibilityHint(summary.accessibilityHint)
        } else {
            Button(action: { model.performPeekAction() }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.title)
                        .font(.headline)
                        .foregroundStyle(PawTheme.ink)
                    Text(summary.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(PawTheme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(emptyActionTitle(summary.action))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PawTheme.cobalt)
                        .frame(minHeight: 44, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
            }
            .buttonStyle(.plain)
            .pawCard(radius: 22)
            .accessibilityIdentifier("peek.empty")
            .accessibilityHint(summary.accessibilityHint)
        }
    }

    private var brandBar: some View {
        HStack(spacing: 6) {
            HStack(spacing: 6) {
                Text(DemoCopy.brandName)
                    .font(.subheadline.weight(.semibold))
                Text(DemoCopy.brandMark)
                    .font(.subheadline)
                Image(systemName: "pawprint.fill")
                    .font(.footnote)
                    .foregroundStyle(PawTheme.cobalt)
            }
            .foregroundStyle(PawTheme.ink)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(DemoCopy.brandName) \(DemoCopy.brandMark)")
            Spacer(minLength: 8)
            Button(action: { model.toggleFavoritesOnly() }) {
                Image(systemName: model.state.favoritesOnly ? "bookmark.fill" : "bookmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(PawTheme.cobalt)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.92), in: Circle())
                    .overlay(Circle().strokeBorder(PawTheme.line, lineWidth: 1))
            }
            .accessibilityIdentifier("favorite.filter")
            .accessibilityLabel(model.state.favoritesOnly ? "仅看收藏，已开启" : "仅看收藏")
            .accessibilityAddTraits(model.state.favoritesOnly ? .isSelected : [])
        }
        .padding(.horizontal, 6)
    }

    private func detail(_ place: Place) -> some View {
        let distance = ExploreLogic.distance(for: place, state: model.state)
        return VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    photo(place)
                    HStack(alignment: .top, spacing: 8) {
                        Text(place.name)
                            .font(.title.weight(.semibold))
                            .foregroundStyle(PawTheme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Button {
                            model.toggleFavorite(place.id)
                        } label: {
                            Image(systemName: model.isFavorite(place.id) ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                                .foregroundStyle(PawTheme.cobalt)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityIdentifier("favorite.place")
                        .accessibilityLabel(model.isFavorite(place.id) ? "取消收藏\(place.name)" : "收藏\(place.name)")
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(distance.primary) · \(place.kindLabel)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(PawTheme.ink)
                            .accessibilityLabel("\(distance.accessibilityLabel)，\(place.kindLabel)")
                        Text("\(place.district) · \(distance.detailNote)")
                            .font(.footnote)
                            .foregroundStyle(PawTheme.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    attributes(place)
                    Text(DemoCopy.unverifiedBadge)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(PawTheme.secondary)
                        .frame(minHeight: 32, alignment: .leading)
                    if model.state.detent == .large {
                        extendedNotes(place)
                        accessRules(place)
                        if let assessment = ExploreLogic.assessment(for: place, state: model.state) {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(assessment.lines, id: \.self) { line in
                                    Text(line)
                                        .font(.footnote)
                                        .foregroundStyle(PawTheme.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        Button(place.isLocalDraft ? "这是本地草稿" : "记下到访观察") {
                            if !place.isLocalDraft {
                                model.contributionPlaceID = place.id
                            }
                        }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(PawTheme.cobalt)
                        .frame(minHeight: 44)
                        .disabled(place.isLocalDraft)
                    }
                    Button(model.state.detent == .large ? "收起" : "完整说明") {
                        model.setDetent(model.state.detent == .large ? .peek : .large)
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(PawTheme.cobalt)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("sheet.more")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            VStack(spacing: 6) {
                Button {
                    model.confirmRoute(for: place)
                } label: {
                    ZStack {
                        HStack(spacing: 8) {
                            Image(systemName: "figure.walk")
                            Text(DemoCopy.routeButtonTitle)
                        }
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .padding(.trailing, 16)
                        }
                    }
                }
                .buttonStyle(PawPrimaryButtonStyle())
                .accessibilityIdentifier("route.button")
                .accessibilityHint(DemoCopy.routeBoundary)
                Text(DemoCopy.routeFootnote)
                    .font(.footnote)
                    .foregroundStyle(PawTheme.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, max(bottomInset, 12))
            .background(PawTheme.card)
            .overlay(alignment: .top) {
                Rectangle().fill(PawTheme.line).frame(height: 1)
            }
        }
    }

    private func photo(_ place: Place) -> some View {
        PlacePhoto(place: place, cornerRadius: 18)
            .frame(height: model.state.detent == .large ? 196 : 156)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topLeading) {
                Button {
                    model.setDetent(.peek)
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(PawTheme.ink)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("取消选择")
                .padding(8)
            }
            .overlay(alignment: .bottomLeading) {
                Text(DemoCopy.photoBadge)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PawTheme.ink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(10)
                    .accessibilityHidden(true)
            }
    }

    private func attributes(_ place: Place) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DemoCopy.attributeNote)
                .font(.caption)
                .foregroundStyle(PawTheme.secondary)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) {
                    attribute(symbol: "pawprint", title: place.leash.title, dot: false)
                    attribute(symbol: "square.dashed", title: place.fenceTitle, dot: false)
                    attribute(symbol: "drop.fill", title: place.waterTitle, dot: place.water)
                }
                VStack(alignment: .leading, spacing: 8) {
                    attribute(symbol: "pawprint", title: place.leash.title, dot: false)
                    attribute(symbol: "square.dashed", title: place.fenceTitle, dot: false)
                    attribute(symbol: "drop.fill", title: place.waterTitle, dot: place.water)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(DemoCopy.attributeNote)。\(place.leash.title)，\(place.fenceTitle)，\(place.waterTitle)")
    }

    private func attribute(symbol: String, title: String, dot: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(PawTheme.ink)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(PawTheme.ink)
            if dot {
                Circle()
                    .fill(PawTheme.amber)
                    .frame(width: 7, height: 7)
                    .accessibilityHidden(true)
            }
        }
    }

    private func accessRules(_ place: Place) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("准入规则")
                .font(.headline)
            if place.category == .mall || place.accessRules.contains(where: { $0.topic == .eachStore }) {
                Text("商场或场地的整体信息，不等于每一家店铺都允许携犬。")
                    .font(.footnote)
                    .foregroundStyle(PawTheme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(place.accessRules, id: \.topic) { rule in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(rule.topic.title)：\(ruleValueTitle(rule.value))")
                        .font(.subheadline)
                    Text("\(rule.condition) 来源：\(rule.source)。最后确认：\(rule.lastConfirmedAt == nil ? "没有" : "有记录")。")
                        .font(.caption)
                        .foregroundStyle(PawTheme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PawTheme.mapBackdrop, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func ruleValueTitle(_ value: RuleValue) -> String {
        switch value {
        case .unknown: "未知"
        case .statedAllowed: "有说法称允许，未确认"
        case .statedRestricted: "有说法称不允许，未确认"
        case .conflict: "有冲突，未覆盖"
        case .confirmedAllowed: "已确认允许"
        case .confirmedRestricted: "已确认不允许"
        }
    }

    private func extendedNotes(_ place: Place) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("这个示例怎么读")
                .font(.headline)
                .foregroundStyle(PawTheme.ink)
            Text(DemoCopy.readingGuide)
                .font(.subheadline)
                .foregroundStyle(PawTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(place.blurb)
                .font(.subheadline)
                .foregroundStyle(PawTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(DemoCopy.photoExplanation)
                .font(.footnote)
                .foregroundStyle(PawTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PawTheme.mapBackdrop, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func emptyActionTitle(_ action: PeekSummary.Action) -> String {
        switch action {
        case .openSuggested: "查看"
        case .showAll: "看全部地点"
        case .clearSearchAndFilters: "清除搜索和筛选"
        }
    }
}
