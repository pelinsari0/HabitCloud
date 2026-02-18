//
//  AddHabitView.swift
//  HabitCloud
//
//  Created by Ravan Afandiyev on 18.02.26.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    @State private var title = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = Color.blue
    @State private var selectedDays: Set<Int> = []
    
    let icons = [
        "star.fill", "heart.fill", "bolt.fill", "leaf.fill",
        "flame.fill", "book.fill", "pencil", "dumbbell.fill",
        "figure.walk", "bed.double.fill", "cup.and.saucer.fill", "fork.knife",
        "water.waves", "brain.head.profile", "hands.sparkles.fill", "music.note"
    ]
    
    let colors: [Color] = [
        .blue, .purple, .pink, .red,
        .orange, .yellow, .green, .teal,
        .indigo, .cyan, .mint, .brown
    ]
    
    let weekdays = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit Name", text: $title)
                } header: {
                    Text("Name")
                }
                
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color.accentColor : Color(.systemGray5))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Icon")
                }
                
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Color")
                }
                
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            ForEach(weekdays, id: \.0) { day in
                                Button(action: {
                                    if selectedDays.contains(day.0) {
                                        selectedDays.remove(day.0)
                                    } else {
                                        selectedDays.insert(day.0)
                                    }
                                }) {
                                    Text(day.1)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedDays.contains(day.0) ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(selectedDays.contains(day.0) ? Color.accentColor : Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        if selectedDays.isEmpty {
                            Text("No days selected = daily habit")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Schedule")
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await habitsViewModel.createHabit(
                                title: title,
                                icon: selectedIcon,
                                colorHex: selectedColor.toHex(),
                                schedule: Array(selectedDays).sorted()
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || habitsViewModel.isLoading)
                }
            }
        }
    }
}
