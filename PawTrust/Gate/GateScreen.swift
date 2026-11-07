import PhotosUI
import SwiftUI
import PawTrustCore

struct GateScreen: View {
    @Bindable var model: ExploreModel
    @State private var photoItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let banner = model.screenshotBanner {
                    Text(banner)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PawTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(PawTheme.cobalt, lineWidth: 1)
                        )
                }
                header
                retentionCard
                captureButtons
                profileFields
                actions
                if let status = model.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(PawTheme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
        }
        .background(PawTheme.mapBackdrop)
        .accessibilityIdentifier(model.screenshotRequest == .profile ? "screen.profile" : "screen.gate")
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { @MainActor in
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await model.ingest(image)
                }
                photoItem = nil
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                Task { @MainActor in await model.ingest(image) }
            }
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.largeTitle)
                .foregroundStyle(PawTheme.cobalt)
                .accessibilityHidden(true)
            Text("\(DemoCopy.brandName) \(DemoCopy.brandMark)")
                .font(.title.weight(.semibold))
                .foregroundStyle(PawTheme.ink)
            Text("第一版给养狗的人，用来看日常遛狗和周末出行。打开地图前先在这台设备上建立犬只档案。")
                .font(.body)
                .foregroundStyle(PawTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var retentionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("敏感信息怎么处理")
                .font(.headline)
            Text(DemoCopy.retentionSummary)
                .font(.subheadline)
                .foregroundStyle(PawTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("识别用的是设备上的文字识别。正式核验还没有接入，所以正式模式不会打开地图。识别到“犬证”或点保存，都不是审核通过。")
                .font(.subheadline)
                .foregroundStyle(PawTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("清除本机档案不会删除相册原图。应用切到后台时会丢掉正在处理的画面。内存和系统截图不能被证明绝对没有残留。")
                .font(.footnote)
                .foregroundStyle(PawTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .pawCard(radius: 20)
    }

    private var captureButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("从相册选择证件照片", systemImage: "photo")
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(PawPrimaryButtonStyle())
            .accessibilityHint("照片只在内存里识别，不写入本应用的存储。")
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button {
                    showCamera = true
                } label: {
                    Label("拍摄证件，不存相册", systemImage: "camera")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.bordered)
                .tint(PawTheme.cobalt)
            }
            #if DEBUG
            Button("填入合成示例文字（不是真实证件）") {
                model.discardSensitiveMaterial()
                model.applyRecognizedLines(ScreenshotBootstrap.syntheticLines)
            }
            .font(.subheadline.weight(.semibold))
            .frame(minHeight: 44)
            .accessibilityHint("调试用的合成文本。不会被当作真实审核。")
            #endif
        }
    }

    private var profileFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本机犬只档案")
                .font(.headline)
            labeledField("犬名（可选）", keyPath: \.dogName)
            labeledField("品种", keyPath: \.breed)
            labeledField("性别", keyPath: \.sex)
            labeledField("年龄段", keyPath: \.ageBand)
            labeledField("体型", keyPath: \.size)
            labeledField("性格，或和其他狗的相处", keyPath: \.temperament)
            labeledField("出行偏好", keyPath: \.outing)
            Toggle(isOn: Binding(
                get: { model.draft.learningEnabled },
                set: { model.setLearning($0) }
            )) {
                Text("允许从检索推断偏好")
                    .font(.subheadline)
            }
            .tint(PawTheme.cobalt)
            Text("推断只改“系统推断”的空字段，不覆盖你填过的内容，也不上传，也不训练模型。关闭后会清掉推断字段。")
                .font(.footnote)
                .foregroundStyle(PawTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .pawCard(radius: 20)
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("保存到这台设备") { model.saveLocalProfile() }
                .buttonStyle(PawPrimaryButtonStyle())
            Button("清除本机档案") { model.clearLocalProfile() }
                .font(.body.weight(.semibold))
                .frame(minHeight: 44)
            Button("请求核验") { model.requestVerification() }
                .font(.body.weight(.semibold))
                .frame(minHeight: 44)
                .accessibilityHint(DemoCopy.verifierUnavailable)
            if model.channel == .debug {
                Button("进入演示地图（不是审核通过）") { model.enterExplicitDemo() }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(PawTheme.cobalt)
                    .frame(minHeight: 44)
                    .accessibilityHint("只在调试构建显示。地图上的地点规则仍然未核实。")
            }
        }
    }

    private func labeledField(_ title: String, keyPath: WritableKeyPath<DogProfile, Attributed<String>>) -> some View {
        let origin = model.draft[keyPath: keyPath].origin
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(originLabel(origin))
                    .font(.caption)
                    .foregroundStyle(PawTheme.secondary)
            }
            TextField(title, text: Binding(
                get: { model.draft[keyPath: keyPath].value ?? "" },
                set: { newValue in
                    model.draft[keyPath: keyPath] = Attributed(
                        value: newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : newValue,
                        origin: newValue.isEmpty ? .empty : .userEntered
                    )
                }
            ))
            .font(.body)
            .padding(10)
            .background(PawTheme.mapBackdrop, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func originLabel(_ origin: ValueOrigin) -> String {
        switch origin {
        case .userEntered: "你填写的"
        case .systemInferred: "系统推断"
        case .empty: "空"
        }
    }
}
