//
//  HabitDetailView.swift
//  HabitCloud
//
//  Created by Ravan Afandiyev on 18.02.26.
//

import SwiftUI
import FirebaseAuth

struct HabitDetailView: View {
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    let habit: Habit
    
    @StateObject private var viewModel: HabitDetailViewModel
    
    init(habit: Habit) {
        self.habit = habit
        _viewModel = StateObject(wrappedValue: HabitDetailViewModel(habit: habit, userId: AuthService.shared.currentUser?.uid ?? ""))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: habit.colorHex))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: habit.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    Text(habit.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Streak
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("\(viewModel.streak)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("day streak")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
                
                // Calendar
                VStack(alignment: .leading, spacing: 12) {
                    Text("Calendar")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    CalendarMonthView(viewModel: viewModel)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Schedule Info
                if !habit.schedule.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Schedule")
                            .font(.headline)
                        
                        Text(scheduleString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var scheduleString: String {
        let dayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let selectedDays = habit.schedule.sorted().compactMap { dayNames[$0] }
        
        if selectedDays.isEmpty {
            return "Daily"
        } else {
            return selectedDays.joined(separator: ", ")
        }
    }
}
