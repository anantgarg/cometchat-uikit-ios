require 'xcodeproj'

project_path = 'CometChatUIKitSwift.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get CometChatUIKitSwift target
target = project.targets.find { |t| t.name == 'CometChatUIKitSwift' }

# Find the SwiftUI file to add
swiftui_file_path = 'Components/Extensions/Thumbnail Generation/ThumbnailGenerationExtensionSwiftUI.swift'
swiftui_file_ref = nil

# First try to find the file by path
swiftui_file_ref = project.files.find { |f| f.path == swiftui_file_path }

# If not found, try to find by name
if swiftui_file_ref.nil?
  swiftui_file_ref = project.files.find { |f| f.path.end_with?('ThumbnailGenerationExtensionSwiftUI.swift') }
end

# If still not found, we need to add the file to the project
if swiftui_file_ref.nil?
  # Find the group for Thumbnail Generation
  thumbnail_generation_group = nil
  
  # Try to find the Extensions group first
  extensions_group = nil
  project.groups.each do |group|
    if group.name == 'Extensions'
      extensions_group = group
      break
    end
  end
  
  # Then try to find the Thumbnail Generation group
  if extensions_group
    extensions_group.groups.each do |group|
      if group.name == 'Thumbnail Generation'
        thumbnail_generation_group = group
        break
      end
    end
  end

  if thumbnail_generation_group
    # Add the file to the project
    file_path = "CometChatUIKitSwift/#{swiftui_file_path}"
    if File.exist?(file_path)
      swiftui_file_ref = thumbnail_generation_group.new_file(file_path)
      puts "Added SwiftUI file to project"
    else
      puts "SwiftUI file not found on disk: #{file_path}"
    end
  else
    puts "Thumbnail Generation group not found"
  end
end

# Add the SwiftUI file to the target
if swiftui_file_ref
  puts "Found SwiftUI file: #{swiftui_file_ref.path}"
  unless target.source_build_phase.files.any? { |f| f.file_ref == swiftui_file_ref }
    target.add_file_references([swiftui_file_ref])
    puts "Added SwiftUI file to target"
  else
    puts "SwiftUI file already in target"
  end
else
  puts "SwiftUI file not found"
end

# Find the UIKit file to remove
uikit_file_path = 'Components/Extensions/Thumbnail Generation/ThumbnailGenerationExtension.swift'
uikit_file_ref = project.files.find { |f| f.path == uikit_file_path }

# If not found by path, try to find by name
if uikit_file_ref.nil?
  uikit_file_ref = project.files.find { |f| f.path.end_with?('ThumbnailGenerationExtension.swift') }
end

if uikit_file_ref
  puts "Found UIKit file: #{uikit_file_ref.path}"
  # Remove the UIKit file from all targets
  project.targets.each do |t|
    t.source_build_phase.files.each do |build_file|
      if build_file.file_ref == uikit_file_ref
        t.source_build_phase.remove_build_file(build_file)
        puts "Removed UIKit file from target: #{t.name}"
      end
    end
  end
else
  puts "UIKit file not found"
end

# Save the project
project.save
puts "Project saved"
