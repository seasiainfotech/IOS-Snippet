import Foundation

/// Represents a user in the application
struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String

    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
    }
}

/// Custom error types for network operations
enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

/// Service responsible for fetching users from API
final class UserService {
    private let baseURL = "https://api.example.com/users"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    /// Fetch all users asynchronously
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.requestFailed
        }
        
        do {
            return try JSONDecoder().decode([User].self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

/// Example usage in SwiftUI or main app
@main
struct MyApp {
    static func main() async {
        let userService = UserService()
        
        do {
            let users = try await userService.fetchUsers()
            print("Users fetched successfully: \(users.count) found.")
        } catch {
            print("Failed to fetch users:", error)
        }
    }
}
