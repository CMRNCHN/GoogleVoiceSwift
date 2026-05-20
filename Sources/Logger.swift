import Foundation
import os

public enum GoogleVoiceLogger {
    private static let logger = Logger(subsystem: "com.googlevoice.swift", category: "GoogleVoice")
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    public static func log(_ message: String, subsystem: String = "GoogleVoiceSwift") {
        let timestamp = formatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(subsystem)] \(message)"
        logger.info("\(logMessage)")
        #if DEBUG
        print(logMessage)
        #endif
    }

    public static func debug(_ message: String, subsystem: String = "GoogleVoiceSwift") {
        let timestamp = formatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(subsystem)] [DEBUG] \(message)"
        logger.debug("\(logMessage)")
        #if DEBUG
        print(logMessage)
        #endif
    }

    public static func error(_ message: String, subsystem: String = "GoogleVoiceSwift") {
        let timestamp = formatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(subsystem)] [ERROR] \(message)"
        logger.error("\(logMessage)")
        #if DEBUG
        print(logMessage)
        #endif
    }
}
