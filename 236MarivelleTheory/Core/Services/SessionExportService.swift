import Foundation

enum SessionExportService {
    static func csv(from sessions: [ActivitySession]) -> String {
        var lines = ["Date,Activity,Spot,Wind km/h,Gusts km/h,Direction,Notes"]
        let formatter = ISO8601DateFormatter()
        for session in sessions.sorted(by: { $0.date > $1.date }) {
            let notes = session.notes
                .replacingOccurrences(of: "\"", with: "\"\"")
            let row = [
                formatter.string(from: session.date),
                session.activity.title,
                "\"\(session.spotName)\"",
                String(format: "%.1f", session.windSpeed),
                String(format: "%.1f", session.windGusts),
                "\(session.windDirection)",
                "\"\(notes)\""
            ].joined(separator: ",")
            lines.append(row)
        }
        return lines.joined(separator: "\n")
    }
}
