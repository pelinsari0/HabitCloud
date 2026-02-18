
import SwiftUI

struct StatusChip: View {
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.caption)
            Text(isCompleted ? "Done" : "Pending")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
        .foregroundColor(isCompleted ? .green : .gray)
        .cornerRadius(12)
    }
}
