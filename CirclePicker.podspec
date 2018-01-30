Pod::Spec.new do |s|
  s.name         = "CirclePicker"
  s.version      = "0.0.1"
  s.summary      = "A custom UIView for multiple choice selection"

  s.description  = <<-DESC
CirclePicker is a custom UIVIew. It allows multiple choice selection of different elements which can be customised by the programmer. Furthermore you can configure CirclePicker for your own needs with multiple parameters.
                   DESC
  s.homepage     = "https://github.com/shutdownr/circlepicker"
  s.license      = "MIT"
  s.author       = "Tim Kreuzer"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/shutdownr/circlepicker.git", :tag => s.version }
  s.swift_version = "4.0"
  s.source_files = "CirclePicker/CirclePicker/CirclePicker*.swift"
end
