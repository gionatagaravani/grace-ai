import Foundation
import Observation
import Supabase

@Observable
@MainActor
class BibleDownloadManager {
    /// Tracks download progress for each translation by its ID (e.g. "asv")
    var downloadProgress: [String: Double] = [:]
    
    // Mapping for human-readable names
    private let translationNames: [String: String] = [
        "asv": "American Standard Version (ASV)",
        "asvs": "American Standard Version (Strong's)",
        "bishops": "Bishops' Bible",
        "coverdale": "Coverdale Bible",
        "geneva": "Geneva Bible",
        "kjv": "King James Version (KJV)",
        "kjv_strongs": "King James Version (Strong's)",
        "net": "New English Translation (NET)",
        "tyndale": "Tyndale Bible",
        "web": "World English Bible (WEB)",
        "diodati": "La Sacra Bibbia (Diodati)"
    ]
    
    // MARK: - API
    
    /// Fetches the list of available translations from Supabase Storage
    func fetchAvailableTranslations() async throws -> [BibleTranslationMeta] {
        let client = SupabaseManager.shared.client
        let files = try await client.storage.from("bibles").list()
        
        let baseURL = "https://idzkgqplossyajtdnbbx.supabase.co/storage/v1/object/public/bibles/"
        
        return files.compactMap { file in
            guard file.name.lowercased().hasSuffix(".json") else { return nil }
            let id = file.name.replacingOccurrences(of: ".json", with: "")
            let name = translationNames[id] ?? id.uppercased()
            let urlString = baseURL + file.name
            guard let url = URL(string: urlString) else { return nil }
            
            return BibleTranslationMeta(id: id, name: name, url: url)
        }
    }
    
    /// Checks whether the translation JSON is already downloaded
    func isDownloaded(translationID: String) -> Bool {
        let fileURL = getFileURL(for: translationID)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    // Delegate to track download progress
    private class BibleProgressDelegate: NSObject, URLSessionDownloadDelegate {
        var onProgress: ((Double) -> Void)?
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            if totalBytesExpectedToWrite > 0 {
                let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
                onProgress?(progress)
            }
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) { }
    }

    /// Downloads the JSON file asynchronously, tracks progress, and saves to FileManager
    func downloadBible(translationID: String, url: URL) async throws {
        // Initialize progress
        self.downloadProgress[translationID] = 0.0
        
        let delegate = BibleProgressDelegate()
        delegate.onProgress = { [weak self] progress in
            Task { @MainActor in
                self?.downloadProgress[translationID] = progress
            }
        }
        
        let request = URLRequest(url: url)
        let (tempURL, response) = try await URLSession.shared.download(for: request, delegate: delegate)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let fileURL = getFileURL(for: translationID)
        
        // Remove existing file if any
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        // Move from temp location to Document Directory
        try FileManager.default.moveItem(at: tempURL, to: fileURL)
        
        // Sync with Supabase
        try? await registerWithSupabase(translationID: translationID)
        
        // Ensure final progress is set
        self.downloadProgress[translationID] = 1.0
        
        // Give UI a moment to reflect 100% before cleaning up
        try? await Task.sleep(nanoseconds: 300_000_000)
        self.downloadProgress.removeValue(forKey: translationID)
    }
    
    /// Deletes the local Bible translation file from the Document Directory
    func deleteBible(translationID: String) {
        let fileURL = getFileURL(for: translationID)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted \(translationID) successfully to free up space.")
                
                // Unregister from Supabase
                Task {
                    try? await unregisterFromSupabase(translationID: translationID)
                }
            } catch {
                print("Failed to delete local bible file: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Supabase Sync Helpers
    
    private func registerWithSupabase(translationID: String) async throws {
        guard let userId = SupabaseManager.shared.currentUserID else { return }
        
        struct DownloadedBible: Encodable {
            let user_id: UUID
            let bible_id: String
        }
        
        let data = DownloadedBible(user_id: userId, bible_id: translationID)
        
        try await SupabaseManager.shared.client.database
            .from("downloaded_bibles")
            .upsert(data) // Use upsert to avoid duplicate errors
            .execute()
    }
    
    private func unregisterFromSupabase(translationID: String) async throws {
        guard let userId = SupabaseManager.shared.currentUserID else { return }
        
        try await SupabaseManager.shared.client.database
            .from("downloaded_bibles")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("bible_id", value: translationID)
            .execute()
    }
    
    /// Loads and parses the downloaded JSON file into the structured App Model
    func loadLocalBible(translationID: String) throws -> BibleTranslation? {
        let fileURL = getFileURL(for: translationID)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        // Read file contents
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        
        // Decode into the flat response model
        let decodedResponse = try decoder.decode(BibleTranslationResponse.self, from: data)
        
        // Convert the flat verses into structural Book/Chapter/Verse hierarchy for the UI
        return decodedResponse.toAppModel()
    }
    
    // MARK: - Private Helpers
    
    /// Generates the local file URL in the App's Document Directory
    private func getFileURL(for translationID: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("\(translationID).json")
    }
}
