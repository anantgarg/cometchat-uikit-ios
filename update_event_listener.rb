require 'xcodeproj'

project_path = "CometChatUIKitSwift.xcodeproj"
project = Xcodeproj::Project.open(project_path)

# Find the target
target = project.targets.find { |t| t.name == "CometChatUIKitSwift" }

# Find the SwiftUI event listener file or create it if it doesn't exist
swiftui_file_path = "CometChatUIKitSwift/Components/Users/UsersViewModelSwiftUI + UsersEventListener.swift"
swiftui_file = nil

# Find the file in the project
project.files.each do |file|
  if file.path.end_with?("UsersViewModelSwiftUI + UsersEventListener.swift")
    puts "Found SwiftUI event listener file: #{file.path}"
    swiftui_file = file
  end
end

# Find the group containing the Users files
users_group = nil
project.groups.each do |group|
  group.recursive_children.each do |child|
    if child.is_a?(Xcodeproj::Project::Object::PBXFileReference) && child.path.end_with?("UsersViewModel.swift")
      users_group = child.parent
      break
    end
  end
  break if users_group
end

# If SwiftUI file doesn't exist in the project, add it
if swiftui_file.nil? && users_group
  puts "Adding SwiftUI event listener file to project"
  swiftui_file = users_group.new_file(swiftui_file_path.split('/').last)
end

# Add SwiftUI file to target if not already added
if swiftui_file
  is_swiftui_file_in_target = target.source_build_phase.files.any? { |bf| bf.file_ref == swiftui_file }
  if !is_swiftui_file_in_target
    target.add_file_references([swiftui_file])
    puts "Added #{swiftui_file.path} to target #{target.name}"
  else
    puts "#{swiftui_file.path} is already in target #{target.name}"
  end
else
  puts "SwiftUI event listener file not found and could not be created"
end

# Save the project
project.save
