require 'xcodeproj'

project_path = "CometChatUIKitSwift.xcodeproj"
project = Xcodeproj::Project.open(project_path)

# Find the target
target = project.targets.find { |t| t.name == "CometChatUIKitSwift" }

# Find the UIKit file reference
uikit_file_path = "CometChatUIKitSwift/Components/Users/UsersViewModel.swift"
uikit_file = nil

# Find the SwiftUI file or create it if it doesn't exist
swiftui_file_path = "CometChatUIKitSwift/Components/Users/UsersViewModelSwiftUI.swift"
swiftui_file = nil

# Find the files in the project
project.files.each do |file|
  if file.path.end_with?("UsersViewModel.swift")
    puts "Found UIKit file: #{file.path}"
    uikit_file = file
  elsif file.path.end_with?("UsersViewModelSwiftUI.swift")
    puts "Found SwiftUI file: #{file.path}"
    swiftui_file = file
  end
end

# Find the group containing the UIKit file
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
  puts "Adding SwiftUI file to project"
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
  puts "SwiftUI file not found and could not be created"
end

# Remove UIKit file from all targets
if uikit_file
  removed = false
  project.targets.each do |t|
    t.source_build_phase.files.each do |bf|
      if bf.file_ref == uikit_file
        t.source_build_phase.remove_build_file(bf)
        puts "Removed #{uikit_file.path} from target #{t.name}"
        removed = true
      end
    end
  end
  if !removed
    puts "#{uikit_file.path} was not found in any target"
  end
else
  puts "UIKit file not found"
end

# Save the project
project.save
