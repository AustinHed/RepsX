//
//  SelectThemeView.swift
//  RepsX
//
//  Created by Austin Hed on 3/4/25.
//

import SwiftUI
import SwiftData

struct SelectThemeView: View {
    
    //Fetch all themes
    @Query(sort: \UserTheme.name) var userThemes: [UserTheme]
    //fetch selected theme
    @Query(filter: #Predicate<UserTheme> { $0.isSelected }) var selectedThemes: [UserTheme]
    var selectedTheme: UserTheme {
        selectedThemes.first ?? UserTheme(name: "Default Theme",
                                          primaryHex: "#007AFF",
                                          secondaryHex: "#8E8E93"
        )
    }
    
    //modelContext
    @Environment(\.modelContext) private var modelContext
    //View Model
    private var userThemeViewModel: UserThemeViewModel {
        UserThemeViewModel(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationStack{
            List{
                //theme options
                ForEach(userThemes) { userTheme in
                    Button {
                        userThemeViewModel.selectCurrentTheme(userTheme)
                    } label: {
                        HStack{
                            if userTheme.isSelected {
                                HStack{
                                    Text(userTheme.name)
                                        .foregroundStyle(.black)
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(hexString: userTheme.primaryHex))
                                }
                            } else {
                                Text(userTheme.name)
                                    .foregroundStyle(.black)
                            }
                            
                            Spacer()
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(hexString: userTheme.primaryHex))
                                .padding(.trailing, 5)
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color(hexString: userTheme.secondaryHex))
                        }
                    }
                }
                
                //Workout & Exercise
                Section("Example Workout") {
                    HStack{
                        Text("Workout Name")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color(hexString:selectedTheme.primaryHex))
                    }
                    //completed set
                    HStack{
                        //count
                        Text("1")
                            .font(.caption)
                            .bold()
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .stroke(Color(hexString:selectedTheme.primaryHex),
                                            lineWidth: 1.5
                                           )
                            )
                            .padding(.trailing)
                            .foregroundColor(Color(hexString:selectedTheme.primaryHex))
                        //lbs
                        VStack(alignment: .leading){
                            Text("Lbs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("5")
                                .frame(maxWidth: 50, maxHeight: 15)
                                .offset(x: -20, y: 0)
                            
                        }
                        //reps
                        VStack(alignment: .leading){
                            Text("Reps")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("10")
                                .frame(maxWidth: 50, maxHeight: 15)
                                .offset(x: -18, y: 0)
                        }
                        //intensity
                        VStack(alignment:.leading){
                            Text("Intensity")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            //intensity bar
                            HStack(spacing: 2) {
                                ForEach(0..<5, id: \.self) { index in
                                    Rectangle()
                                        .foregroundColor(Color(hexString:selectedTheme.primaryHex))
                                }
                            }
                            // The white background shows through as the gap lines between segments.
                            .background(Color.white)
                            .frame(height: 15)
                            .cornerRadius(18)
                        }
                        .padding(.horizontal,8)
                        .frame(maxHeight: 5)
                    }
                    //non-completed set
                    HStack{
                        //count
                        Text("1")
                            .font(.caption)
                            .bold()
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .stroke(.secondary,
                                            lineWidth: 1.5
                                           )
                            )
                            .padding(.trailing)
                            .foregroundColor(.secondary)
                        //lbs
                        VStack(alignment: .leading){
                            Text("Lbs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("0")
                                .frame(maxWidth: 50, maxHeight: 15)
                                .offset(x: -20, y: 0)
                                .foregroundStyle(.gray)
                            
                        }
                        //reps
                        VStack(alignment: .leading){
                            Text("Reps")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("0")
                                .frame(maxWidth: 50, maxHeight: 15)
                                .offset(x: -18, y: 0)
                                .foregroundStyle(.gray)
                        }
                        //intensity
                        VStack(alignment:.leading){
                            Text("Intensity")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            //intensity bar
                            HStack(spacing: 2) {
                                ForEach(0..<5, id: \.self) { index in
                                    Rectangle()
                                        .foregroundColor(index < 3 ? Color(hexString:selectedTheme.primaryHex).opacity(0.6) : Color.gray.opacity(0.5))
                                }
                            }
                            // The white background shows through as the gap lines between segments.
                            .background(Color.white)
                            .frame(height: 15)
                            .cornerRadius(18)
                        }
                        .padding(.horizontal,8)
                        .frame(maxHeight: 5)
                    }
                    Text("Add Set")
                        .foregroundStyle(Color(hexString: selectedTheme.primaryHex))
                }
                
                //Timer
                Section("Example Timer"){
                    HStack{
                        Text("Start")
                            .font(.headline)
                            .foregroundColor(Color(hexString: selectedTheme.primaryHex))
                            .padding(.leading, 40)
                        Spacer()
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding(.trailing, 40)
                        
                    }
                    .overlay(
                        ZStack {
                            // The progress circle using .trim to reflect the remaining time smoothly
                            Circle()
                                .stroke(Color(hexString: selectedTheme.primaryHex), lineWidth: 5)
                                .rotationEffect(.degrees(-90))
                                .frame(width: 60, height: 60)
                            
                            // The time string in MM:SS format
                            Text("1:30")
                                .font(.headline)
                        }
                    )
                    .frame(height: 80)
                }
            }
            .navigationTitle("Select Theme")
            
        }
    }
}

#Preview {
    SelectThemeView()
        .modelContainer(for: [Workout.self, Exercise.self, Set.self, ExerciseTemplate.self, CategoryModel.self, Routine.self, ExerciseInRoutine.self, UserTheme.self])
}







