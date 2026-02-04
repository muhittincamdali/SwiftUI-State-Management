Pod::Spec.new do |s|
  s.name             = 'SwiftUIStateManagement'
  s.version          = '1.0.0'
  s.summary          = 'State management solutions for SwiftUI applications.'
  s.description      = <<-DESC
    SwiftUIStateManagement provides comprehensive state management patterns for SwiftUI.
    Features include Redux-like store, @Observable integration, dependency injection,
    and reactive state handling with Combine and async/await support.
  DESC

  s.homepage         = 'https://github.com/muhittincamdali/SwiftUI-State-Management'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/SwiftUI-State-Management.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation', 'SwiftUI', 'Combine'
end
