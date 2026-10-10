import SwiftUI
import WidgetKit

struct WirdEntry: TimelineEntry {
    let date: Date
    let completed: Int
    let total: Int
    var english: Bool = false
}
struct WirdProvider: TimelineProvider {
    func placeholder(in context: Context) -> WirdEntry { WirdEntry(date: Date(), completed: 0, total: 0) }
    func entry(at date: Date) -> WirdEntry {
        let prefs = UserDefaults(suiteName: "group.ae.wird.app")
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US_POSIX")
        format.calendar = Calendar(identifier: .gregorian)
        format.dateFormat = "yyyy-MM-dd"
        let isToday = prefs?.string(forKey: "day") == format.string(from: date)
        return WirdEntry(date: date, completed: isToday ? (prefs?.integer(forKey: "completed") ?? 0) : 0,
                         total: prefs?.integer(forKey: "total") ?? 0, english: prefs?.string(forKey: "language") == "en")
    }
    func getSnapshot(in context: Context, completion: @escaping (WirdEntry) -> Void) { completion(entry(at: Date())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WirdEntry>) -> Void) {
        let now = Date()
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: now)!)
        completion(Timeline(entries: [entry(at: now), entry(at: midnight)], policy: .after(midnight)))
    }
}
struct WirdWidgetView: View {
    var entry: WirdEntry
    var content: some View {
        VStack(spacing: 8) {
            Text("ورد — Wird").font(.headline)
            Text(entry.english ? "Today’s progress" : "متابعتك اليوم").font(.subheadline)
            if entry.total > 0 { Text("\(entry.completed) / \(entry.total)").font(.title).bold() }
            else { Text(entry.english ? "Open Wird to begin" : "افتح ورد للبدء") }
            Text(entry.date, style: .date).font(.caption2)
        }.foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
         .environment(\.layoutDirection, entry.english ? .leftToRight : .rightToLeft)
    }
    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(Color(red: 0.15, green: 0.24, blue: 0.25), for: .widget)
        } else {
            content.padding().background(Color(red: 0.15, green: 0.24, blue: 0.25))
        }
    }
}
@main
struct WirdWidget: Widget {
    let kind = "WirdWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WirdProvider()) { entry in WirdWidgetView(entry: entry) }
            .configurationDisplayName("ورد — Wird")
            .description("متابعة أذكارك اليومية على جهازك")
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}
