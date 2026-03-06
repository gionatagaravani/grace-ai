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
    
    /// Downloads the JSON file asynchronously, tracks progress, and saves to FileManager
    func downloadBible(translationID: String, url: URL) async throws {
        // Initialize progress
        downloadProgress[translationID] = 0.0
        
        let urlSession = URLSession.shared
        let (asyncBytes, response) = try await urlSession.bytes(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let expectedLength = response.expectedContentLength
        // Typical JSON for ~6MB text
        var data = Data()
        data.reserveCapacity(Int(expectedLength > 0 ? expectedLength : 6_000_000))
        
        var downloadedBytes = 0
        let updateThreshold = 100 * 1024 // Update UI every 100 KB
        
        for try await byte in asyncBytes {
            data.append(byte)
            downloadedBytes += 1
            
            // Periodically update the published progress to prevent heavy UI re-renders
            if expectedLength > 0 && downloadedBytes % updateThreshold == 0 {
                let progress = Double(downloadedBytes) / Double(expectedLength)
                self.downloadProgress[translationID] = progress
            }
        }
        
        // Ensure final progress is set
        self.downloadProgress[translationID] = 1.0
        
        // Save the downloaded memory data to disk
        let fileURL = getFileURL(for: translationID)
        try data.write(to: fileURL)
        
        // Cleanup progress state once completed
        self.downloadProgress.removeValue(forKey: translationID)
    }
    
    /// Deletes the local Bible translation file from the Document Directory
    func deleteBible(translationID: String) {
        let fileURL = getFileURL(for: translationID)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted \(translationID) successfully to free up space.")
            } catch {
                print("Failed to delete local bible file: \(error.localizedDescription)")
            }
        }
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
