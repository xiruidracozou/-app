import SwiftUI
import PawTrustCore

struct ContributionComposer: View {
    @Bindable var model: ExploreModel
    @Environment(\.dismiss) private var dismiss

    @State private var sentence = ""
    @State private var name = ""
    @State private var city: City = .shanghai
    @State private var category: PlaceCategory = .walking
    @State private var topic: RuleTopic = .petEntry
    @State private var observation: Observation = .unknown
    @State private var condition = ""
    @State private var sourceNote = "到访观察"
    @State private var observedDay = ""
    @State private var notice: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("用一句话整理，再由你确认") {
                    TextField("例如：有围栏，能不能放绳我不确定", text: $sentence, axis: .vertical)
                        .lineLimit(3...6)
                    Button("整理成待确认字段") {
                        let draft = FeedbackOrganizer.organize(
                            sentence,
                            knownPlaceNames: model.state.places.map(\.name)
                        )
                        if let hint = draft.placeNameHint { name = hint }
                        if let topic = draft.topic { self.topic = topic }
                        observation = draft.observation
                        if !draft.condition.isEmpty { condition = draft.condition }
                        if let day = draft.observedDay { observedDay = day }
                        notice = draft.note
                    }
                    .frame(minHeight: 44)
                }
                Section("地点") {
                    TextField("名称", text: $name)
                    Picker("城市", selection: $city) {
                        ForEach(City.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    Picker("类别", selection: $category) {
                        ForEach(PlaceCategory.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    if model.contributionPlaceID == nil {
                        Button("使用当前地图中心") {
                            if let center = model.mapCenter {
                                notice = String(format: "地点位置 %.5f, %.5f。这不是行动路线。", center.latitude, center.longitude)
                            } else {
                                notice = "先打开地图并移动画面，再使用中心点。"
                            }
                        }
                        .frame(minHeight: 44)
                    }
                }
                Section("这一条规则") {
                    Picker("字段", selection: $topic) {
                        ForEach(RuleTopic.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    Picker("观察", selection: $observation) {
                        Text("未知").tag(Observation.unknown)
                        Text("观察者称是").tag(Observation.observerSaysYes)
                        Text("观察者称否").tag(Observation.observerSaysNo)
                        Text("观察者不确定").tag(Observation.observerUnsure)
                    }
                    TextField("适用条件", text: $condition)
                    TextField("来源说明", text: $sourceNote)
                    TextField("明确日期，如 2026-05-01", text: $observedDay)
                        .accessibilityHint("不记录星期习惯或路线。")
                    Text("保存后的状态是：仅在本机、待审核、未同步。它不会变成已确认规则，也不会对其他人可见。")
                        .font(.footnote)
                        .foregroundStyle(PawTheme.secondary)
                }
                if let notice {
                    Section {
                        Text(notice)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(model.contributionPlaceID == nil ? "添加地点" : "到访记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        model.contributionPlaceID = nil
                        model.showNewPlace = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存在本机") { save() }
                }
            }
            .onAppear(perform: prefill)
        }
    }

    private func prefill() {
        if let id = model.contributionPlaceID, let place = model.place(id) {
            name = place.name
            city = place.city
            category = place.category
        } else if let filter = model.state.cityFilter {
            city = filter
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            notice = "先写地点名称。"
            return
        }
        let isNew = model.contributionPlaceID == nil
        let coordinate = isNew ? model.mapCenter : nil
        if isNew, coordinate == nil {
            notice = "新地点需要一个地图中心。移动地图后再保存。"
            return
        }
        let day = observedDay.trimmingCharacters(in: .whitespacesAndNewlines)
        let item = LocalContribution(
            kind: isNew ? "addPlace" : "fieldNote",
            placeID: model.contributionPlaceID,
            placeName: trimmed,
            city: city.rawValue,
            category: category.rawValue,
            latitude: coordinate?.latitude,
            longitude: coordinate?.longitude,
            topic: topic.rawValue,
            observation: observation.rawValue,
            condition: condition,
            sourceNote: sourceNote,
            observedDay: day.isEmpty ? nil : day
        )
        if let blocked = model.saveContribution(item) {
            notice = blocked
            return
        }
        model.contributionPlaceID = nil
        model.showNewPlace = false
        dismiss()
    }
}
