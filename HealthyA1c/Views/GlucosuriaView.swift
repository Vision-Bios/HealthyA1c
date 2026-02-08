import SwiftUI
import PhotosUI
import UIKit

struct GlucosuriaView: View {
    @StateObject private var viewModel = GlucosuriaViewModel()
    @StateObject private var paletteViewModel = HbA1cViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var sampledColor: UIColor?
    @State private var matchedLevel: GlucosuriaLevel?
    @State private var sampledPoint: CGPoint?
    @State private var date = Date()
    @State private var editingEntry: GlucosuriaEntry?
    @State private var showCamera = false
    @State private var showCameraError = false
    @State private var addPulse = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        ZStack {
            ThemeBackgroundView(palette: paletteViewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Glucosuria")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Dipstick photo")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                Text(image == nil ? "Add photo" : "Replace photo")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(paletteViewModel.selectedPalette.cardBackground,
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }

                        Button {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showCamera = true
                            } else {
                                showCameraError = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera")
                                Text("Take photo")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(paletteViewModel.selectedPalette.cardBackground,
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        if let image {
                            ZStack(alignment: .center) {
                                GeometryReader { geo in
                                    let rect = aspectFitRect(imageSize: image.size, in: geo.size)
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onEnded { value in
                                                    let location = value.location
                                                    guard rect.contains(location) else { return }
                                                    sampledPoint = location
                                                    sampledColor = sampleColor(from: image,
                                                                               in: rect,
                                                                               at: location)
                                                    matchedLevel = sampledColor.map(matchLevel(from:))
                                                }
                                        )

                                    if let sampledColor, let sampledPoint {
                                        Circle()
                                            .fill(Color(uiColor: sampledColor))
                                            .frame(width: 18, height: 18)
                                            .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 2))
                                            .position(sampledPoint)
                                    }
                                }
                            }
                            .frame(height: 240)
                        }

                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                        if let matchedLevel {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(matchedLevel.color)
                                    .frame(width: 14, height: 14)
                                Text("Detected: \(matchedLevel.title)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(paletteViewModel.selectedPalette.textColor)
                            }
                        } else {
                            Text("Tap the dipstick area to sample the color.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Button("Add Result") {
                            guard let matchedLevel else { return }
                            viewModel.addEntry(date: date, level: matchedLevel)
                            FunFeedback.shared.success()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                                addPulse = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                addPulse = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(paletteViewModel.selectedPalette.glow)
                        .disabled(matchedLevel == nil)
                        .scaleEffect(addPulse ? 1.06 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.55), value: addPulse)
                    }
                    .padding(16)
                    .background(paletteViewModel.selectedPalette.cardBackground,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Legend")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                        ForEach(GlucosuriaLevel.allCases) { level in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(level.color)
                                    .frame(width: 22, height: 22)
                                Text(level.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(paletteViewModel.selectedPalette.textColor)
                                Spacer()
                                Text(level.mmol == 0 ? "Negative" : "\(Int(level.mmol)) mmol/L")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(16)
                    .background(paletteViewModel.selectedPalette.cardBackground,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Graph")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                        GlucosuriaGraphView(entries: viewModel.entries)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("History")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                        ForEach(viewModel.entries.reversed()) { entry in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(entry.level.color)
                                    .frame(width: 12, height: 12)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.level.title)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(paletteViewModel.selectedPalette.textColor)
                                    Text(dateFormatter.string(from: entry.date))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(Int(entry.mmol)) mmol/L")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(paletteViewModel.selectedPalette.cardBackground,
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .onTapGesture {
                                editingEntry = entry
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteEntry(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .environment(\.colorScheme, paletteViewModel.selectedPalette.preferredScheme)
        .onAppear {
            paletteViewModel.load()
            viewModel.load()
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    image = uiImage.normalizedImage()
                    sampledColor = nil
                    matchedLevel = nil
                    sampledPoint = nil
                }
            }
        }
        .onChange(of: image) { _, newImage in
            if newImage != nil {
                sampledColor = nil
                matchedLevel = nil
                sampledPoint = nil
            }
        }
        .sheet(item: $editingEntry) { entry in
            GlucosuriaEditSheet(entry: entry,
                                palette: paletteViewModel.selectedPalette,
                                onDelete: {
                                    viewModel.deleteEntry(entry)
                                }) { updatedLevel, updatedDate in
                viewModel.updateEntry(id: entry.id, date: updatedDate, level: updatedLevel)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $image)
        }
        .alert("Camera unavailable", isPresented: $showCameraError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device does not have a camera.")
        }
    }

    private func matchLevel(from color: UIColor) -> GlucosuriaLevel {
        GlucosuriaLevel.allCases.min(by: {
            labDistance(color, $0.uiColor) < labDistance(color, $1.uiColor)
        }) ?? .negative
    }

    private func aspectFitRect(imageSize: CGSize, in container: CGSize) -> CGRect {
        let scale = min(container.width / imageSize.width, container.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        let x = (container.width - width) / 2
        let y = (container.height - height) / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func sampleColor(from image: UIImage, in rect: CGRect, at location: CGPoint) -> UIColor? {
        guard rect.contains(location) else { return nil }
        guard let cgImage = image.cgImage else { return nil }
        let nx = (location.x - rect.minX) / rect.width
        let ny = (location.y - rect.minY) / rect.height
        let px = Int(nx * CGFloat(cgImage.width))
        let py = Int(ny * CGFloat(cgImage.height))
        return image.averageColorAtPixel(x: px, y: py, radius: 10)
    }
}

#Preview {
    GlucosuriaView()
}

private struct GlucosuriaEditSheet: View {
    let entry: GlucosuriaEntry
    let palette: GraphPalette
    let onDelete: () -> Void
    let onSave: (GlucosuriaLevel, Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel: GlucosuriaLevel
    @State private var date: Date

    init(entry: GlucosuriaEntry,
         palette: GraphPalette,
         onDelete: @escaping () -> Void,
         onSave: @escaping (GlucosuriaLevel, Date) -> Void) {
        self.entry = entry
        self.palette = palette
        self.onDelete = onDelete
        self.onSave = onSave
        _selectedLevel = State(initialValue: entry.level)
        _date = State(initialValue: entry.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Level", selection: $selectedLevel) {
                    ForEach(GlucosuriaLevel.allCases) { level in
                        Text(level.title).tag(level)
                    }
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Edit Result")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete", role: .destructive) {
                        onDelete()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(selectedLevel, date)
                        dismiss()
                    }
                }
            }
        }
        .tint(palette.glow)
    }
}

private extension UIImage {
    func averageColorAtPixel(x: Int, y: Int, radius: Int) -> UIColor? {
        guard let cgImage = cgImage else { return nil }
        guard let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = cgImage.bytesPerRow

        let cx = max(0, min(x, width - 1))
        let cy = max(0, min(y, height - 1))

        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var totalA: CGFloat = 0
        var count: CGFloat = 0

        let r = max(1, radius)
        for dx in -r...r {
            for dy in -r...r {
                if dx * dx + dy * dy > r * r { continue }
                let px = max(0, min(cx + dx, width - 1))
                let py = max(0, min(cy + dy, height - 1))
                let index = py * bytesPerRow + px * bytesPerPixel
                totalR += CGFloat(bytes[index]) / 255.0
                totalG += CGFloat(bytes[index + 1]) / 255.0
                totalB += CGFloat(bytes[index + 2]) / 255.0
                totalA += CGFloat(bytes[index + 3]) / 255.0
                count += 1
            }
        }

        guard count > 0 else { return nil }
        return UIColor(red: totalR / count,
                       green: totalG / count,
                       blue: totalB / count,
                       alpha: totalA / count)
    }

    func normalizedImage() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

private extension GlucosuriaView {
    func labDistance(_ a: UIColor, _ b: UIColor) -> CGFloat {
        let labA = a.toLab()
        let labB = b.toLab()
        let dl = (labA.l - labB.l) * 0.6
        let da = labA.a - labB.a
        let db = labA.b - labB.b
        return sqrt(dl * dl + da * da + db * db)
    }
}

private struct LabColor {
    let l: CGFloat
    let a: CGFloat
    let b: CGFloat
}

private extension UIColor {
    func toLab() -> LabColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = (r, g, b)
        let xyz = rgbToXYZ(rgb)
        return xyzToLab(xyz)
    }

    private func rgbToXYZ(_ rgb: (CGFloat, CGFloat, CGFloat)) -> (CGFloat, CGFloat, CGFloat) {
        func linearize(_ c: CGFloat) -> CGFloat {
            if c <= 0.04045 { return c / 12.92 }
            return pow((c + 0.055) / 1.055, 2.4)
        }
        let r = linearize(rgb.0)
        let g = linearize(rgb.1)
        let b = linearize(rgb.2)
        let x = r * 0.4124 + g * 0.3576 + b * 0.1805
        let y = r * 0.2126 + g * 0.7152 + b * 0.0722
        let z = r * 0.0193 + g * 0.1192 + b * 0.9505
        return (x, y, z)
    }

    private func xyzToLab(_ xyz: (CGFloat, CGFloat, CGFloat)) -> LabColor {
        let refX: CGFloat = 0.95047
        let refY: CGFloat = 1.00000
        let refZ: CGFloat = 1.08883

        func f(_ t: CGFloat) -> CGFloat {
            let delta: CGFloat = 6.0 / 29.0
            if t > pow(delta, 3) {
                return pow(t, 1.0 / 3.0)
            }
            return (t / (3 * pow(delta, 2))) + (4.0 / 29.0)
        }

        let fx = f(xyz.0 / refX)
        let fy = f(xyz.1 / refY)
        let fz = f(xyz.2 / refZ)
        let l = max(0, (116 * fy) - 16)
        let a = 500 * (fx - fy)
        let b = 200 * (fy - fz)
        return LabColor(l: l, a: a, b: b)
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let original = info[.originalImage] as? UIImage {
                parent.image = original.normalizedImage()
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
