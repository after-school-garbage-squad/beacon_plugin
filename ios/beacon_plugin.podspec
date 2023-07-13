#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint beacon_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'beacon_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Beacon scanning library for Re:paint app on iOS / Android'
  s.description      = <<-DESC
Beacon scanning library for Re:paint app on iOS / Android
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
