import SwiftUI
import PhotosUI
import Combine
import UIKit
import AVFoundation
import AudioToolbox

// MARK: - Main App
@main
struct SmartPantryMobileApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// MARK: - Recipe Model
struct Recipe: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let ingredients: [String]
    let instructions: [String]
    let prepTime: String
    let cookTime: String
    let difficulty: String
    let servings: Int
    let nutrition: NutritionInfo?
    let healthRating: String?
    let dietaryInfo: [String]?
    let timerSteps: [TimerStep]?
    
    struct NutritionInfo: Codable {
        let calories: String
        let carbs: String
        let protein: String
        let fat: String
    }
    
    struct TimerStep: Codable {
        let stepNumber: Int
        let instruction: String
        let duration: Int // in minutes
        let description: String
    }
    
    // Computed property for health color
    var healthColor: Color {
        switch healthRating?.lowercased() {
        case "healthy": return .green
        case "moderately healthy": return .orange
        case "unhealthy": return .red
        default: return .gray
        }
    }
    
    // Computed property for health icon
    var healthIcon: String {
        switch healthRating?.lowercased() {
        case "healthy": return "heart.fill"
        case "moderately healthy": return "heart"
        case "unhealthy": return "heart.slash"
        default: return "questionmark.circle"
        }
    }
}

// MARK: - Ingredient Health Model
struct IngredientHealth {
    let name: String
    let healthRating: String
    
    var healthColor: Color {
        switch healthRating.lowercased() {
        case "healthy": return .green
        case "moderately healthy": return .orange
        case "unhealthy": return .red
        default: return .gray
        }
    }
    
    var healthIcon: String {
        switch healthRating.lowercased() {
        case "healthy": return "leaf.fill"
        case "moderately healthy": return "leaf"
        case "unhealthy": return "exclamationmark.triangle.fill"
        default: return "questionmark.circle"
        }
    }
}

// MARK: - Recipes View
struct RecipesView: View {
    @EnvironmentObject var networkManager: PantryNetworkManager
    @State private var isLoading = false
    @State private var recipes: [Recipe] = []
    @State private var errorMessage: String?
    @State private var selectedRecipe: Recipe?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 16) {
                    Image(systemName: "book.closed.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange.opacity(0.7))
                    
                    Text("Recipe Suggestions")
                        .font(.title)
                        .fontWeight(.bold)
                    
                            Text("AI-powered recipes based on your pantry")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                    
                        // Generate Button
                        Button(action: generateRecipes) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "sparkles")
                                Text("Generate Recipes")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                    .disabled(networkManager.pantryItems.isEmpty || isLoading)
                    
                        // Pantry Status
                    if networkManager.pantryItems.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "basket")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("Your pantry is empty")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Add items to your pantry first to get recipe suggestions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                        } else {
                            Text("Using \(networkManager.pantryItems.count) items from your pantry")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                        
                        // Recipes List
                        if !recipes.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Suggested Recipes")
                                        .font(.title2)
                                        .fontWeight(.bold)
                    
                    Spacer()
                                    
                                    Button("Clear") {
                                        recipes = []
                                    }
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                }
                                .padding(.horizontal)
                                
                                LazyVStack(spacing: 16) {
                                    ForEach(recipes) { recipe in
                                        RecipeCard(recipe: recipe) {
                                            selectedRecipe = recipe
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Recipes")
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
    
    private func generateRecipes() {
        guard !networkManager.pantryItems.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let newRecipes = try await networkManager.generateRecipes()
                await MainActor.run {
                    self.recipes = newRecipes
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate recipes: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Recipe Card
struct RecipeCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Recipe Header with Health Rating
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(recipe.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            // Health Rating Badge
                            if let healthRating = recipe.healthRating {
                                HStack(spacing: 4) {
                                    Image(systemName: recipe.healthIcon)
                                        .font(.caption2)
                                    Text(healthRating)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(recipe.healthColor.opacity(0.2))
                                .foregroundColor(recipe.healthColor)
                                .cornerRadius(8)
                            }
                        }
                        
                        Text(recipe.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Recipe Info
                HStack(spacing: 16) {
                    InfoBadge(icon: "clock", text: recipe.prepTime)
                    InfoBadge(icon: "flame", text: recipe.cookTime)
                    InfoBadge(icon: "person.2", text: "\(recipe.servings)")
                    InfoBadge(icon: "chart.bar", text: recipe.difficulty)
                }
                
                // Key Ingredients
                VStack(alignment: .leading, spacing: 4) {
                    Text("Key Ingredients")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(recipe.ingredients.prefix(3).joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Info Badge
struct InfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.1))
        .foregroundColor(.orange)
        .cornerRadius(8)
    }
}

// MARK: - Ingredient Chip
struct IngredientChip: View {
    let ingredient: String
    
    private var healthInfo: IngredientHealth {
        getIngredientHealth(ingredient)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: healthInfo.healthIcon)
                .font(.caption2)
            Text(ingredient)
                .font(.caption2)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(healthInfo.healthColor.opacity(0.15))
        .foregroundColor(healthInfo.healthColor)
        .cornerRadius(8)
    }
    
    private func getIngredientHealth(_ ingredient: String) -> IngredientHealth {
        let lowercased = ingredient.lowercased()
        
        // Healthy ingredients
        if lowercased.contains("vegetable") || lowercased.contains("broccoli") || 
           lowercased.contains("spinach") || lowercased.contains("carrot") ||
           lowercased.contains("tomato") || lowercased.contains("onion") ||
           lowercased.contains("garlic") || lowercased.contains("lettuce") ||
           lowercased.contains("cucumber") || lowercased.contains("pepper") ||
           lowercased.contains("avocado") || lowercased.contains("lemon") ||
           lowercased.contains("lime") || lowercased.contains("apple") ||
           lowercased.contains("banana") || lowercased.contains("berry") ||
           lowercased.contains("chicken breast") || lowercased.contains("salmon") ||
           lowercased.contains("egg") || lowercased.contains("yogurt") ||
           lowercased.contains("oat") || lowercased.contains("quinoa") ||
           lowercased.contains("brown rice") || lowercased.contains("olive oil") ||
           lowercased.contains("almond") || lowercased.contains("walnut") {
            return IngredientHealth(name: ingredient, healthRating: "Healthy")
        }
        
        // Unhealthy ingredients
        else if lowercased.contains("sugar") || lowercased.contains("butter") ||
                lowercased.contains("cream") || lowercased.contains("cheese") ||
                lowercased.contains("bacon") || lowercased.contains("sausage") ||
                lowercased.contains("fried") || lowercased.contains("processed") ||
                lowercased.contains("white bread") || lowercased.contains("pasta") ||
                lowercased.contains("soda") || lowercased.contains("candy") ||
                lowercased.contains("chocolate") || lowercased.contains("cake") ||
                lowercased.contains("cookie") || lowercased.contains("chips") {
            return IngredientHealth(name: ingredient, healthRating: "Unhealthy")
        }
        
        // Moderately healthy ingredients
        else {
            return IngredientHealth(name: ingredient, healthRating: "Moderately Healthy")
        }
    }
}

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Recipe Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(recipe.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // Health Rating Badge
                            if let healthRating = recipe.healthRating {
                                HStack(spacing: 6) {
                                    Image(systemName: recipe.healthIcon)
                                        .font(.title3)
                                    Text(healthRating)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(recipe.healthColor.opacity(0.2))
                                .foregroundColor(recipe.healthColor)
                                .cornerRadius(12)
                            }
                        }
                        
                        Text(recipe.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Recipe Stats
                        HStack(spacing: 20) {
                            StatItem(icon: "clock", label: "Prep", value: recipe.prepTime)
                            StatItem(icon: "flame", label: "Cook", value: recipe.cookTime)
                            StatItem(icon: "person.2", label: "Serves", value: "\(recipe.servings)")
                            StatItem(icon: "chart.bar", label: "Level", value: recipe.difficulty)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text(ingredient)
                                    .font(.body)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(instruction)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    // Show timer if this step has a timer
                                    if let timerSteps = recipe.timerSteps,
                                       let timerStep = timerSteps.first(where: { $0.stepNumber == index + 1 }) {
                                        TimerButton(timerStep: timerStep)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    // Dietary Information
                    if let dietaryInfo = recipe.dietaryInfo, !dietaryInfo.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dietary Information")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 12) {
                                ForEach(dietaryInfo, id: \.self) { info in
                                    Text(info)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    
                    // Nutrition Info
                    if let nutrition = recipe.nutrition {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Nutrition (per serving)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 20) {
                                NutritionItem(label: "Calories", value: nutrition.calories)
                                NutritionItem(label: "Carbs", value: nutrition.carbs)
                                NutritionItem(label: "Protein", value: nutrition.protein)
                                NutritionItem(label: "Fat", value: nutrition.fat)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.05), Color.pink.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Nutrition Item
struct NutritionItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Timer Button
struct TimerButton: View {
    let timerStep: Recipe.TimerStep
    @State private var timeRemainingSeconds: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: isRunning ? "timer.circle.fill" : "timer")
                    .font(.caption)
                    .foregroundColor(isRunning ? .green : .orange)
                
                Text("⏱️ \(timerStep.description)")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                if isRunning {
                    Text(formatTime(timeRemainingSeconds))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .monospacedDigit()
                } else {
                    Text("\(timerStep.duration) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: toggleTimer) {
                    HStack(spacing: 4) {
                        Image(systemName: isRunning ? "stop.fill" : "play.fill")
                            .font(.caption2)
                        Text(isRunning ? "Stop" : "Start")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isRunning ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                    .foregroundColor(isRunning ? .red : .green)
                    .cornerRadius(8)
                }
            }
            
            // Progress bar
            if isRunning {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(LinearGradient(
                                colors: [.green, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * progress, height: 4)
                            .animation(.linear(duration: 0.5), value: progress)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(isRunning ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(8)
        .onAppear {
            totalSeconds = timerStep.duration * 60
            timeRemainingSeconds = totalSeconds
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - timeRemainingSeconds) / Double(totalSeconds)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isRunning = true
        
        // Fire immediately and then every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemainingSeconds > 0 {
                timeRemainingSeconds -= 1
            } else {
                stopTimer()
                playCompletionSound()
                showCompletionAlert()
            }
        }
        
        // Ensure timer fires immediately
        timer?.fire()
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        timeRemainingSeconds = totalSeconds
    }
    
    private func playCompletionSound() {
        // Play system sound for timer completion
        #if os(iOS)
        AudioServicesPlaySystemSound(1005) // SMS received sound
        #endif
    }
    
    private func showCompletionAlert() {
        // Haptic feedback
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}

// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var username = ""
    @State private var password = ""
    @State private var showingSignup = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo and Title
                    VStack(spacing: 16) {
                        // Try to load logo from static folder, fallback to SF Symbol
                        if let uiImage = UIImage(named: "static_logo") ?? UIImage(named: "logo") {
                            ZStack {
                                // Purple to dark blue background for white logo
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(LinearGradient(
                                        colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .colorMultiply(.white) // Keep logo white
                            }
                        } else {
                            // Fallback to custom SF Symbol design
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(LinearGradient(
                                        colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "cabinet.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("SmartPantry")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Your intelligent kitchen companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username or Email")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter username or email", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textContentType(.username)
                                .autocorrectionDisabled(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            SecureField("Enter password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.password)
                        }
                        
                        Button(action: login) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Login")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 5)
                        }
                        .disabled(username.isEmpty || password.isEmpty || authManager.isLoading)
                        
                        if let error = authManager.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Signup Link
                    HStack {
                        Text("Don't have an account?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Sign Up") {
                            showingSignup = true
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignup) {
                SignupView()
                    .environmentObject(authManager)
            }
        }
    }
    
    private func login() {
        Task {
            await authManager.login(username: username, password: password)
        }
    }
}

// MARK: - Signup View
struct SignupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 16) {
                            // Try to load logo from static folder, fallback to SF Symbol
                            if let uiImage = UIImage(named: "static_logo") ?? UIImage(named: "logo") {
                                ZStack {
                                    // Purple to dark blue background for white logo
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(LinearGradient(
                                            colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 100, height: 100)
                                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                                    
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 85, height: 85)
                                        .colorMultiply(.white) // Keep logo white
                                }
                            } else {
                                // Fallback to custom SF Symbol design
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(LinearGradient(
                                            colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "cabinet.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text("Create Account")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Join SmartPantry and start managing your kitchen")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Signup Form
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter username", text: $username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .textContentType(.username)
                                    .autocorrectionDisabled(true)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .textContentType(.emailAddress)
                                    .autocorrectionDisabled(true)
                                    .disableAutocorrection(true)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                SecureField("Enter password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.newPassword)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                SecureField("Confirm password", text: $confirmPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.newPassword)
                            }
                            
                            Button(action: signup) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "person.badge.plus")
                                        Text("Create Account")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(radius: 5)
                            }
                            .disabled(username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || authManager.isLoading)
                            
                            if let error = authManager.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func signup() {
        guard password == confirmPassword else {
            return
        }
        
        Task {
            await authManager.signup(username: username, email: email, password: password)
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var networkManager = PantryNetworkManager()
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .environmentObject(networkManager)
                        .environmentObject(authManager)
            
            MyPantryView()
                .tabItem {
                    Label("My Pantry", systemImage: "basket.fill")
                }
                .environmentObject(networkManager)
                        .environmentObject(authManager)
            
            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                .environmentObject(networkManager)
                        .environmentObject(authManager)
        }
        .accentColor(.purple)
                .onAppear {
                    // Set user ID in network manager when authenticated
                    if let user = authManager.currentUser {
                        networkManager.currentUserId = user.id
                        networkManager.pantryItems = user.pantry
                    }
                }
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

// MARK: - Models
struct PantryResponse: Codable {
    let success: Bool
    let items: [String]
    let count: Int
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidImage
    case itemAlreadyExists
    case itemNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .invalidImage: return "Could not process image"
        case .itemAlreadyExists: return "Item already exists"
        case .itemNotFound: return "Item not found"
        }
    }
}

// MARK: - User Model
struct User: Codable {
    let id: String
    let username: String
    let email: String
    let pantry: [String]
}

// MARK: - Authentication Manager
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://192.168.0.6:5050"
    private let clientType = "mobile"
    
    func signup(username: String, email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard let url = URL(string: "\(baseURL)/api/auth/signup") else {
            await MainActor.run {
                errorMessage = "Invalid URL"
                isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(clientType, forHTTPHeaderField: "X-Client-Type")
        
        let body = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug: Print response details
            if let httpResponse = response as? HTTPURLResponse {
                print("Signup Response Status: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Signup Response Body: \(responseString)")
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                let result = try JSONDecoder().decode(SignupResponse.self, from: data)
                await MainActor.run {
                    self.isAuthenticated = true
                    self.currentUser = User(id: result.userId, username: result.username, email: email, pantry: [])
                    self.isLoading = false
                }
            } else {
                // Try to decode error response
                if let httpResponse = response as? HTTPURLResponse {
                    do {
                        let errorResult = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        await MainActor.run {
                            self.errorMessage = errorResult.error
                            self.isLoading = false
                        }
                    } catch {
                        await MainActor.run {
                            self.errorMessage = "Signup failed: Server error \(httpResponse.statusCode)"
                            self.isLoading = false
                        }
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Invalid response"
                        self.isLoading = false
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Signup failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func login(username: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard let url = URL(string: "\(baseURL)/api/auth/login") else {
            await MainActor.run {
                errorMessage = "Invalid URL"
                isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(clientType, forHTTPHeaderField: "X-Client-Type")
        
        let body = [
            "username": username,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug: Print response details
            if let httpResponse = response as? HTTPURLResponse {
                print("Login Response Status: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Login Response Body: \(responseString)")
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                let result = try JSONDecoder().decode(LoginResponse.self, from: data)
                await MainActor.run {
                    self.isAuthenticated = true
                    self.currentUser = User(id: result.userId, username: result.username, email: result.email, pantry: result.pantry)
                    self.isLoading = false
                }
            } else {
                // Try to decode error response
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 401 {
                        // Try to decode error response
                        do {
                            let errorResult = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            await MainActor.run {
                                self.errorMessage = errorResult.error
                                self.isLoading = false
                            }
                        } catch {
                            await MainActor.run {
                                self.errorMessage = "Invalid credentials"
                                self.isLoading = false
                            }
                        }
                    } else {
                        await MainActor.run {
                            self.errorMessage = "Server error: \(httpResponse.statusCode)"
                            self.isLoading = false
                        }
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Invalid response"
                        self.isLoading = false
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Login failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
    }
}

// MARK: - Authentication Response Models
struct SignupResponse: Codable {
    let success: Bool
    let message: String
    let userId: String
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case success, message, username
        case userId = "user_id"
    }
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let userId: String
    let username: String
    let email: String
    let pantry: [String]
    
    enum CodingKeys: String, CodingKey {
        case success, message, username, email, pantry
        case userId = "user_id"
    }
}

struct ErrorResponse: Codable {
    let success: Bool
    let error: String
}

struct PhotoUploadResponse: Codable {
    let success: Bool
    let message: String
    let items: [String]
    let totalItems: Int
    
    enum CodingKeys: String, CodingKey {
        case success, message, items
        case totalItems = "total_items"
    }
}

// MARK: - Network Manager
class PantryNetworkManager: ObservableObject {
    private let baseURL = "http://192.168.0.6:5050"
    private let clientType = "mobile" // Identifier for mobile app
    
    @Published var isOnline = false
    @Published var pantryItems: [String] = []
    @Published var currentUserId: String?
    
    
    // Upload Photo
    func uploadPhoto(_ image: UIImage) async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/api/upload_photo") else {
            throw NetworkError.invalidURL
        }
        
        let resized = image.resized(maxDimension: 1600)
        guard let imageData = resized.jpegData(compressionQuality: 0.7) else {
            throw NetworkError.invalidImage
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(clientType, forHTTPHeaderField: "X-Client-Type")
        if let userId = currentUserId {
            request.setValue(userId, forHTTPHeaderField: "X-User-ID")
        }
        
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Safely append boundary data
        guard let boundaryData = "--\(boundary)\r\n".data(using: .utf8),
              let dispositionData = "Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8),
              let contentTypeData = "Content-Type: image/jpeg\r\n\r\n".data(using: .utf8),
              let endBoundaryData = "\r\n--\(boundary)--\r\n".data(using: .utf8) else {
            throw NetworkError.invalidData
        }
        
        body.append(boundaryData)
        body.append(dispositionData)
        body.append(contentTypeData)
        body.append(imageData)
        body.append(endBoundaryData)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // Parse the JSON response
        let uploadResponse = try JSONDecoder().decode(PhotoUploadResponse.self, from: data)
        
        // Refresh pantry items after upload
        try await loadPantryItems()
        return uploadResponse.items
    }
    
    // Load Pantry Items
    func loadPantryItems() async throws {
        guard let url = URL(string: "\(baseURL)/api/pantry") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(clientType, forHTTPHeaderField: "X-Client-Type")
        if let userId = currentUserId {
            request.setValue(userId, forHTTPHeaderField: "X-User-ID")
        }
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let pantryResponse = try JSONDecoder().decode(PantryResponse.self, from: data)
        
        await MainActor.run {
            self.pantryItems = pantryResponse.items
        }
    }
    
    // Add Item
    func addPantryItem(_ item: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/pantry") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(clientType, forHTTPHeaderField: "X-Client-Type")
        
        if let userId = currentUserId {
            request.setValue(userId, forHTTPHeaderField: "X-User-ID")
        }
        
        
        let body = ["item": item]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        try await loadPantryItems()
    }
    
    // Delete Item
    func deletePantryItem(_ item: String) async throws {
        let encodedItem = item.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? item
        guard let url = URL(string: "\(baseURL)/api/pantry/\(encodedItem)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(clientType, forHTTPHeaderField: "X-Client-Type")
        if let userId = currentUserId {
            request.setValue(userId, forHTTPHeaderField: "X-User-ID")
        }
        
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        try await loadPantryItems()
    }
    
    // Check Health
    func checkHealth() async {
        guard let url = URL(string: "\(baseURL)/api/health") else { return }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.isOnline = (response as? HTTPURLResponse)?.statusCode == 200
            }
        } catch {
            await MainActor.run {
                self.isOnline = false
            }
        }
    }
    
    // Generate Recipes
    func generateRecipes() async throws -> [Recipe] {
        guard let url = URL(string: "\(baseURL)/api/recipes/suggest") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(clientType, forHTTPHeaderField: "X-Client-Type")
        
        if let userId = currentUserId {
            request.setValue(userId, forHTTPHeaderField: "X-User-ID")
        }
        
        
        let body = ["pantry_items": pantryItems]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
        return recipeResponse.recipes
    }
}

// MARK: - Recipe Response Model
struct RecipeResponse: Codable {
    let success: Bool
    let recipes: [Recipe]
}

// MARK: - Home View (Main Page with Time & Inspiration)
struct HomeView: View {
    @EnvironmentObject var networkManager: PantryNetworkManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    let healthyQuotes = [
        "Let food be thy medicine and medicine be thy food.",
        "You are what you eat, so don't be fast, cheap, easy or fake.",
        "Take care of your body. It's the only place you have to live.",
        "Eat well, live well, be well.",
        "Your diet is a bank account. Good food choices are good investments.",
        "The food you eat can be either the safest and most powerful form of medicine or the slowest form of poison.",
        "Every time you eat is an opportunity to nourish your body.",
        "Healthy eating is a way of life, so it's important to establish routines.",
        "Good nutrition creates health in all areas of our existence.",
        "The greatest wealth is health."
    ]
    
    var dailyQuote: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return healthyQuotes[dayOfYear % healthyQuotes.count]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.08),
                        Color.blue.opacity(0.12),
                        Color.indigo.opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Elegant Header Section
                        VStack(spacing: 16) {
                            // User info and status indicator in top right
                            HStack {
                                Spacer()
                                HStack(spacing: 12) {
                                    // User info
                                    if let user = authManager.currentUser {
                                        HStack(spacing: 6) {
                                            Image(systemName: "person.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.purple)
                                            Text(user.username)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.white.opacity(0.7))
                                                .shadow(color: .black.opacity(0.05), radius: 2)
                                        )
                                    }
                                    
                                    // Status indicator
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(networkManager.isOnline ? Color.green : Color.orange)
                                            .frame(width: 8, height: 8)
                                        Text(networkManager.isOnline ? "Connected" : "Offline")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.7))
                                            .shadow(color: .black.opacity(0.05), radius: 2)
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Refined Welcome Section
                            VStack(spacing: 12) {
                                // Try to load logo from static folder, fallback to SF Symbol
                                if let uiImage = UIImage(named: "static_logo") ?? UIImage(named: "logo") {
                                    ZStack {
                                        // Purple to dark blue background for white logo
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(LinearGradient(
                                                colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .frame(width: 80, height: 80)
                                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                        
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 70, height: 70)
                                            .colorMultiply(.white) // Keep logo white
                                    }
                                } else {
                                    // Fallback to custom SF Symbol design
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(LinearGradient(
                                                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "cabinet.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Text("Good \(greeting)")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                
                                Text("SmartPantry")
                                    .font(.system(size: 36, weight: .light, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Your intelligent kitchen companion")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 20)
                            
                            // Elegant Time Display
                            VStack(spacing: 6) {
                                Text(currentTime, style: .time)
                                    .font(.system(size: 42, weight: .ultraLight, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(currentTime, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            }
                            
                        // Daily Inspiration Card - More Elegant
                        VStack(spacing: 16) {
                                HStack {
                                Image(systemName: "sparkles")
                                    .font(.title3)
                                    .foregroundColor(.purple)
                                    Text("Daily Inspiration")
                                        .font(.headline)
                                    .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                Spacer()
                                }
                                
                                Text(dailyQuote)
                                .font(.body)
                                    .italic()
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                .lineLimit(nil)
                            }
                        .padding(20)
                            .background(
                            RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                            
                        // Refined Stats Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Your Pantry")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                                .padding(.horizontal)
                            
                            // Single elegant stats card
                            HStack(spacing: 20) {
                                VStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.purple.opacity(0.15), .blue.opacity(0.15)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "basket.fill")
                                            .font(.title2)
                                            .foregroundColor(.purple)
                                    }
                                    
                                    Text("\(networkManager.pantryItems.count)")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("Items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Ready to cook")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if networkManager.pantryItems.isEmpty {
                                        Text("Add some items to get started")
                                        .font(.caption)
                                            .foregroundColor(.orange)
                                    } else {
                                        Text("Great selection!")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                                )
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .onAppear {
                currentTime = Date()
                Task {
                    await networkManager.checkHealth()
                    try? await networkManager.loadPantryItems()
                }
            }
        }
    }
    
    // Computed property for greeting based on time
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<22: return "Evening"
        default: return "Night"
        }
    }
}

// MARK: - My Pantry View (Add Items & Current Items)
struct MyPantryView: View {
    @EnvironmentObject var networkManager: PantryNetworkManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var newItem = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isUploadingPhoto = false
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // My Pantry Header
                        HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My Pantry")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Manage your kitchen inventory")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Logout button
                            Button(action: {
                                authManager.logout()
                                networkManager.currentUserId = nil
                                networkManager.pantryItems = []
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // Add Item Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Section Card
                        VStack(alignment: .leading, spacing: 12) {
                            // Header
                            Text("Add New Items")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Type item name or use camera to scan")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            // Manual Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type Item Name")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    TextField("Enter item name...", text: $newItem)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onSubmit {
                                            addItem()
                                        }
                                    
                                    Button(action: addItem) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                    .disabled(newItem.isEmpty || isLoading)
                                }
                            }
                            
                            Divider()
                            
                            // Camera Options
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Or Scan with Camera")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 12) {
                                    Button(action: { showCamera = true }) {
                                        HStack {
                                            Image(systemName: "camera.fill")
                                            Text("Take Photo")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(
                                                colors: [.purple, .blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    
                                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                                        HStack {
                                            Image(systemName: "photo.on.rectangle")
                                            Text("Choose")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            LinearGradient(
                                                colors: [.green, .teal],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            
                            if isUploadingPhoto {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Text("Analyzing photo...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    // Pantry Items Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Section Header with Count
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Items")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                if !networkManager.pantryItems.isEmpty {
                                    Text("\(networkManager.pantryItems.count) items in your pantry")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("No items yet")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if !networkManager.pantryItems.isEmpty {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 50, height: 50)
                                    
                                    Text("\(networkManager.pantryItems.count)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Items Grid or Empty State
                        if networkManager.pantryItems.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "cart")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Your pantry is empty")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Add items or use the camera to scan food")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(Array(networkManager.pantryItems.enumerated()), id: \.offset) { index, item in
                                        PantryItemCard(item: item) {
                                            deleteItem(item)
                                        }
                                    }
                                }
                                .padding()
                        }
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .onChange(of: photoPickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await uploadPhoto(image)
                    }
                }
            }
            .onChange(of: selectedImage) { _, image in
                if let image = image, !showCamera {
                    Task {
                        await uploadPhoto(image)
                    }
                }
            }
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .onAppear {
                currentTime = Date()
                loadItems()
                Task {
                    await networkManager.checkHealth()
                }
            }
        }
    }
    
// MARK: - MyPantryView Actions
extension MyPantryView {
    func addItem() {
        guard !newItem.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await networkManager.addPantryItem(newItem)
                await MainActor.run {
                    newItem = ""
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to add item"
                    isLoading = false
                }
            }
        }
    }
    
    func deleteItem(_ item: String) {
        Task {
            do {
                try await networkManager.deletePantryItem(item)
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete item"
                }
            }
        }
    }
    
    func loadItems() {
        Task {
            do {
                try await networkManager.loadPantryItems()
            } catch {
                print("Failed to load items: \(error)")
            }
        }
    }
    
    func uploadPhoto(_ image: UIImage) async {
        await MainActor.run {
            isUploadingPhoto = true
            errorMessage = nil
            selectedImage = nil
        }
        
        do {
            let items = try await networkManager.uploadPhoto(image)
            await MainActor.run {
                isUploadingPhoto = false
                errorMessage = "✅ Success! Added \(items.count) items to pantry"
                selectedImage = nil
            }
            
            // Clear success message after 3 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                if errorMessage?.contains("✅") == true {
                    errorMessage = nil
                }
            }
        } catch {
            await MainActor.run {
                isUploadingPhoto = false
                errorMessage = "❌ Failed to upload photo: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - UIImage resizing helper
private extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Pantry Item Card
struct PantryItemCard: View {
    let item: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "leaf.fill")
                .foregroundColor(.green)
            
            Text(item.capitalized)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

