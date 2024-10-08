#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tagion_dart_api.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tagion_dart_api'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Decard AG' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64', }
  s.preserve_paths = 'libtauonapi.xcframework/**/*'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework libtauonapi' }
  s.vendored_frameworks = 'libtauonapi.xcframework'
end
