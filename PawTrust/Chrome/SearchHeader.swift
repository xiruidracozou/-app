import SwiftUI
import PawTrustCore

struct SearchHeader: View {
    @Bindable var model: ExploreModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let banner = model.screenshotBanner {
                Text(banner)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PawTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(PawTheme.cobalt, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
            }
            if case .demo(let label) = model.access {
                HStack {
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PawTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    Button("离开演示") { model.leaveDemo() }
                        .font(.caption.weight(.semibold))
                        .frame(minHeight: 44)
                }
                .padding(12)
                .pawCard(radius: 16)
                .padding(.horizontal, 16)
            }
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    searchField
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .background(Color.white, in: Capsule())
                        .overlay(Capsule().strokeBorder(PawTheme.line, lineWidth: 1))
                    nearbyButton
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .background(Color.white, in: Capsule())
                        .overlay(Capsule().strokeBorder(PawTheme.line, lineWidth: 1))
                }
                .padding(.horizontal, 16)
            } else {
                searchBar
                    .padding(.horizontal, 16)
            }
            filterChips
            if let banner = model.banner {
                LocationBannerCard(banner: banner) {
                    model.dismissBanner()
                } openSettings: {
                    SystemSettings.open()
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            searchField
            Rectangle()
                .fill(PawTheme.line)
                .frame(width: 1, height: 22)
            nearbyButton
        }
        .padding(.leading, 14)
        .padding(.trailing, 8)
        .frame(minHeight: 52)
        .background(Color.white, in: Capsule())
        .overlay(Capsule().strokeBorder(PawTheme.line, lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(PawTheme.secondary)
                .accessibilityHidden(true)
            TextField("搜索，或说一句话", text: Binding(
                get: { model.composerText },
                set: { model.applyComposer($0) }
            ))
            .font(.body)
            .foregroundStyle(PawTheme.ink)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .focused($searchFocused)
            .onSubmit { searchFocused = false }
            .accessibilityIdentifier("search.field")
            .accessibilityLabel("搜索示例地点，或说一句话。提交后由本地解析变成筛选，不是语言模型。")
            if !model.composerText.isEmpty || model.state.asksAboutRules {
                Button {
                    model.applyComposer("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(PawTheme.secondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("清除搜索")
            }
        }
    }

    private var nearbyButton: some View {
        Button {
            searchFocused = false
            model.requestNearby()
        } label: {
            HStack(spacing: 6) {
                Text("附近")
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "pawprint.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(PawTheme.cobalt)
                    .frame(width: 22, height: 22)
                    .background(PawTheme.mapBackdrop, in: Circle())
            }
            .foregroundStyle(PawTheme.ink)
            .frame(minWidth: 44, minHeight: 44)
            .padding(.horizontal, 4)
        }
        .accessibilityIdentifier("nearby.button")
        .accessibilityLabel("附近")
        .accessibilityHint("请求定位，并按你的位置排序示例公园")
    }

    @ViewBuilder
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(
                    title: "全部",
                    symbol: "circle.grid.2x2.fill",
                    selected: model.state.filters.isEmpty,
                    identifier: "filter.all"
                ) {
                    model.clearAttributeFilters()
                }
                ForEach(PlaceFilter.allCases, id: \.self) { filter in
                    chip(
                        title: filter.title,
                        symbol: filter.symbolName,
                        selected: model.state.filters.contains(filter),
                        identifier: "filter.\(filter.rawValue)"
                    ) {
                        model.toggleFilter(filter)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .accessibilityLabel("示例筛选")
        if model.state.asksAboutRules || model.state.categoryFilter != nil || !model.state.unmatchedTerms.isEmpty {
            interpretationTags
                .padding(.horizontal, 16)
        }
        cityChips
    }

    private var cityChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "全部城市", symbol: "map", selected: model.state.cityFilter == nil, identifier: "city.all") {
                    model.selectCity(nil)
                }
                ForEach(City.allCases, id: \.self) { city in
                    chip(title: city.title, symbol: "mappin", selected: model.state.cityFilter == city, identifier: "city.\(city.rawValue)") {
                        model.selectCity(city)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
        }
    }

    private var interpretationTags: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DemoCopy.localParseLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(PawTheme.secondary)
            if let category = model.state.categoryFilter {
                Text("类别 · \(category.title)")
                    .font(.caption)
            }
            ForEach(model.state.requiredTopics, id: \.self) { topic in
                HStack {
                    Text(topic.title)
                        .font(.caption.weight(.semibold))
                    Button("移除") { model.removeTopic(topic) }
                        .font(.caption.weight(.semibold))
                        .frame(minHeight: 44)
                }
            }
            if !model.state.unmatchedTerms.isEmpty {
                Text("没有当成条件：\(model.state.unmatchedTerms.joined(separator: "、"))")
                    .font(.caption)
                    .foregroundStyle(PawTheme.secondary)
            }
            Text("未知规则不会被当成已经满足。")
                .font(.caption)
                .foregroundStyle(PawTheme.secondary)
        }
        .padding(12)
        .pawCard(radius: 16)
    }

    private func chip(
        title: String,
        symbol: String,
        selected: Bool,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                Text(title)
            }
        }
        .buttonStyle(ChipButtonStyle(selected: selected))
        .accessibilityIdentifier(identifier)
        .accessibilityLabel("\(title)，示例筛选")
        .accessibilityHint(selected ? "已启用" : "点按后只显示符合的示例地点")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct LocationBannerCard: View {
    let banner: LocationBanner
    let dismiss: () -> Void
    let openSettings: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: banner.symbolName)
                .foregroundStyle(PawTheme.cobalt)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            Text(banner.message)
                .font(.footnote)
                .foregroundStyle(PawTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            if banner.showsSettings {
                Button("打开设置", action: openSettings)
                    .font(.footnote.weight(.semibold))
                    .frame(minHeight: 44)
            }
            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.bold))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("关闭位置提示")
        }
        .padding(.leading, 12)
        .padding(.trailing, 4)
        .padding(.vertical, 4)
        .pawCard(radius: 16)
        .accessibilityElement(children: .contain)
    }
}
