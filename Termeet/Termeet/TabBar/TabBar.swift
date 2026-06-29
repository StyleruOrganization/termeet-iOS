//
//  TabBar.swift
//  Termeet
//
//  Created by Daniil Sukhanov on 01.05.2025.
//
import SwiftUI

private struct LazyView<Content: View>: View {
    let build: () -> Content
    init(@ViewBuilder _ build: @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

/**
 A customizable and reusable tab bar component that supports full visual customization,
 animations, and flexible layout (horizontal or vertical).

 -  Parameters:
    - Content: The type of content view shown for each tab item.
    - Background: The type of background view behind the tab bar.
    - Item: The model used for each tab, must conform to Identifiable.
*/
struct TabBar<Content: View, Background: View, Item: Identifiable>: View {
    @Binding var selected: Item.ID
    private let items: [Item]
    private let content: (Item) -> Content
    private var axis: Axis.Set = .horizontal
    private var background: Background
    private var animationSelect: Animation?

    /**
     Creates a new TabBar.
     
     - Parameters:
         - selected: A binding to the selected item's ID.
         - items: An array of items to be displayed.
         - axis: The layout axis. Default is horizontal.
         - content: A view builder that returns content for each item.
         - background: A view builder for the background. Default is EmptyView.
    */
    init(
        selected: Binding<Item.ID>,
        items: [Item],
        axis: Axis.Set = .horizontal,
        @ViewBuilder content: @escaping (Item) -> Content,
        @ViewBuilder background: @escaping () -> Background = { EmptyView() }
    ) {
        precondition(!items.isEmpty, "TabBar must have at least one item")
        self._selected = selected
        self.items = items
        self.content = content
        self.axis = axis
        self.background = background()
    }

    var body: some View {
        ZStack {
            self.background
            if axis == .horizontal {
                HStack {
                    tabButtons
                }
            } else {
                VStack {
                    tabButtons
                }
            }
        }
    }

    private var tabButtons: some View {
        ForEach(items, id: \.id) { item in
            Button {
                withAnimation(animationSelect) {
                    selected = item.id
                }
            } label: {
                LazyView {
                    content(item)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
            }
            .buttonStyle(.plain)
            .id(item.id)
        }
    }
}

// MARK: - Modifier

extension TabBar {
    /**
     Sets the animation to use when changing the selected tab.
     
     - Parameter animation: A closure returning the desired Animation.
     - Returns: A modified TabBar with the specified animation.
    */
    func onAnimationSelect(_ animation: () -> (Animation?)) -> Self {
        var copy = self
        copy.animationSelect = animation()
        return copy
    }
}

#Preview {
    struct PreviewContainer: View {
        struct TabItem: Identifiable {
            let id: String
            let title: String
            let icon: String
        }

        @State private var selectedID = "home"

        let items = [
            TabItem(id: "home", title: "Home", icon: "house.fill"),
            TabItem(id: "search", title: "Search", icon: "magnifyingglass"),
            TabItem(id: "profile", title: "Profile", icon: "person.fill"),
            TabItem(id: "search2", title: "Search", icon: "magnifyingglass"),
            TabItem(id: "profile2", title: "Profile", icon: "person.fill")
        ]

        var body: some View {
            VStack(spacing: 20) {
                Spacer()
                Text("Selected: \(selectedID)")
                    .font(.title2)
                    .padding()

                TabBar(
                    selected: $selectedID,
                    items: items,
                    axis: .horizontal
                ) { item in
                    VStack {
                        Image(systemName: item.icon)
                            .font(.title2)
                        Text(item.title)
                            .font(.caption)
                    }
                    .foregroundColor(selectedID == item.id ? .blue : .gray)
                } background: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
                }
                .onAnimationSelect { .spring(response: 0.4, dampingFraction: 0.7) }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .frame(maxHeight: 60)
            }
            .padding(.vertical)
            .background(Color(.secondarySystemBackground).ignoresSafeArea())

        }
    }

    return PreviewContainer()
}
