//
//  HabitsListView.swift
//  HabitCloud
//
//  Created by Ravan Afandiyev on 18.02.26.
//

import SwiftUI

struct HabitsListView: View {
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    @State private var showAddHabit = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if habitsViewModel.habits.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Habits Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Tap + to create your first habit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(habitsViewModel.habits) { habit in
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    HabitRow(
                                        habit: habit,
                                        streak: habitsViewModel.habitStreaks[habit.id ?? ""] ?? 0,
                                        isDoneToday: habitsViewModel.habitTodayStatus[habit.id ?? ""] ?? false,
                                        onToggle: {
                                            Task {
                                                await habitsViewModel.toggleTodayStatus(for: habit)
                                            }
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await habitsViewModel.deleteHabit(habit)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddHabit = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
            }
            .alert("Error", isPresented: .constant(habitsViewModel.errorMessage != nil)) {
                Button("OK") {
                    habitsViewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = habitsViewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}
