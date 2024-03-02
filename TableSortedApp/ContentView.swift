//
//  ContentView.swift
//  TableSortedApp
//
//  Created by nicola de filippo on 02/03/24.
//

import SwiftUI


struct Beer: Codable, Identifiable {
    var id: Int
    var name: String
    var first_brewed: String
    var image_url: String
    var abv: Double
}


struct ContentView: View {
    @State var beers: [Beer] = []
    @State var page = 0
    @State private var sortOrder = [KeyPathComparator(\Beer.name, order: .reverse)]
    var body: some View {
        Table(beers, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("First Brew", value: \.first_brewed)
            TableColumn("ABV") { beer in
                Text("\(beer.abv)")
            }
            TableColumn("Image") { beer in
                AsyncImage(url: URL(string: beer.image_url)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                
            }
        }.onAppear {
            Task {
                await getBeers()
            }
        }.onChange(of: sortOrder) {
            beers.sort(using: sortOrder)
       }
    }
    func getBeers() async {
        do {
            page += 1
            let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)&per_page=30")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let beersLoaded = try JSONDecoder().decode([Beer].self, from: data)
            beers = beersLoaded + beers
            beers.sort(using: sortOrder)
        } catch {
            print("Some error")
        }
    }
}

#Preview {
    ContentView()
}
