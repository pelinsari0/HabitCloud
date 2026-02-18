
import SwiftUI

struct DayCell: View {
    let day: Int?
    let isCompleted: Bool
    let isScheduled: Bool
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if let day = day {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 40, height: 40)
                    
                    Text("\(day)")
                        .font(.system(size: 14, weight: isToday ? .bold : .regular))
                        .foregroundColor(textColor)
                } else {
                    Color.clear
                        .frame(width: 40, height: 40)
                }
            }
        }
        .disabled(day == nil)
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isToday {
            return Color.accentColor.opacity(0.3)
        } else if !isScheduled {
            return Color.clear
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        if isCompleted {
            return .white
        } else if !isScheduled {
            return .gray.opacity(0.5)
        } else {
            return .primary
        }
    }
}
