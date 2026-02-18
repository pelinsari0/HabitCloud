//
//  StatsView.swift
//  HabitCloud
//
//  Created by Ravan Afandiyev on 18.02.26.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if habitsViewModel.habits.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "chart.bar")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Stats Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Create habits to see your progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Last 7 Days")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(habitsViewModel.habits) { habit in
                                HabitStatRow(
                                    habit: habit,
                                    logs: habitsViewModel.habitLogs[habit.id ?? ""] ?? []
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}

struct HabitStatRow: View {
    let habit: Habit
    let logs: [HabitLog]
    
    private let streakService = StreakService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.colorHex))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: habit.icon)
                        .font(.body)
                        .foregroundColor(.white)
                }
                
                Text(habit.title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(completionRate * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(completionRate >= 0.7 ? .green : .orange)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color(hex: habit.colorHex))
                        .frame(width: geometry.size.width * completionRate, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            // Last 7 days visualization
            HStack(spacing: 4) {
                ForEach(last7Days.reversed(), id: \.self) { date in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(isCompleted(date: date) ? Color(hex: habit.colorHex) : Color(.systemGray5))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(dayLetter(date: date))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(isCompleted(date: date) ? .white : .secondary)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var completionRate: Double {
        return streakService.getCompletionRate(habit: habit, logs: logs, days: 7)
    }
    
    private var last7Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }
    
    private func isCompleted(date: Date) -> Bool {
        let dateKey = DateService.shared.dateKey(from: date)
        return logs.first(where: { $0.dateKey == dateKey })?.done ?? false
    }
    
    private func dayLetter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}
