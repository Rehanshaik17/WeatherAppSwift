import SwiftUI
import Supabase
import Auth

struct SearchView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            headerView
            
            // Search Bar
            searchBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    if !viewModel.searchQuery.isEmpty {
                        // Search Results Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SEARCH RESULTS")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .kerning(1)
                            
                            VStack(spacing: 12) {
                                if viewModel.isLoading {
                                    ProgressView()
                                } else if viewModel.searchResults.isEmpty {
                                    Text("No cities found")
                                        .foregroundColor(.secondary)
                                } else {
                                    ForEach(viewModel.searchResults, id: \.name) { location in
                                        searchResultRow(for: location)
                                    }
                                }
                            }
                        }
                    } else {
                        // Suggested Cities
                        suggestedCitiesSection
                        
                        // Recent Searches
                        recentSearchesSection
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 24)
        .background(GlassBackground())
        .onAppear {
            Task {
                await viewModel.fetchFavorites()
            }
        }
        .navigationBarHidden(true)
    }
    
    private func searchResultRow(for location: WeatherLocation) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title3)
                .foregroundColor(.blue)
                .padding(12)
                .background(Color.blue.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.headline)
                Text("\(location.region), \(location.country)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.addFavorite(city: location.name)
                    // Also show the weather for this city immediately
                    await weatherViewModel.fetchWeatherData(for: location.name)
                    selectedTab = 0
                }
            } label: {
                Image(systemName: "plus")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .buttonStyle(.borderless)
        }
        .padding(16)
        .liquidGlass(cornerRadius: 24)
        .contentShape(Rectangle())
        .onTapGesture {
            Task {
                await weatherViewModel.fetchWeatherData(for: location.name)
                selectedTab = 0
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button {
                selectedTab = 0
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
            }
            
            Text("City Search")
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
            
            Button {
                // More action
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.top, 20)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search for a city or airport", text: $viewModel.searchQuery)
            
            Image(systemName: "mic.fill")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var suggestedCitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SUGGESTED CITIES")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .kerning(1)
                Spacer()
                Button("View All") {
                    withAnimation {
                        viewModel.searchQuery = " " // Trigger a search with a space to show all or handled logic
                    }
                }
                .font(.caption.bold())
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.suggestedCities, id: \.self) { city in
                    suggestedCityRow(for: city)
                }
            }
        }
    }
    
    private func suggestedCityRow(for city: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "location.fill")
                .font(.title3)
                .foregroundColor(.blue)
                .padding(12)
                .background(Color.blue.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(city)
                    .font(.headline)
                Text("Local City")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.addFavorite(city: city)
                    // Also show the weather for this city immediately
                    await weatherViewModel.fetchWeatherData(for: city)
                    selectedTab = 0
                }
            } label: {
                Image(systemName: "plus")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .buttonStyle(.borderless)
        }
        .padding(16)
        .liquidGlass(cornerRadius: 24)
        .contentShape(Rectangle())
        .onTapGesture {
            Task {
                await weatherViewModel.fetchWeatherData(for: city)
                selectedTab = 0
            }
        }
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("RECENT SEARCHES")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .kerning(1)
                Spacer()
                Button("Clear") {
                    viewModel.clearRecentSearches()
                }
                .font(.caption.bold())
                .foregroundColor(.secondary)
            }
            
            FlowLayout(spacing: 12) {
                ForEach(viewModel.recentSearches, id: \.self) { city in
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                        Text(city)
                            .font(.subheadline.medium())
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .liquidGlass(cornerRadius: 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await weatherViewModel.fetchWeatherData(for: city)
                            selectedTab = 0
                        }
                    }
                }
            }
        }
    }
}

// Simple FlowLayout for recent searches
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        return CGSize(width: width, height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

extension Font {
    func medium() -> Font {
        self.weight(.medium)
    }
}

#Preview {
    SearchView(selectedTab: .constant(1)).environmentObject(AppViewModel())
}
