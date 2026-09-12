require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'MeethalfwayCapacitorFinancekit'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = package['repository']['url']
  s.author = package['author']
  s.source = { :git => package['repository']['url'], :tag => s.version.to_s }
  s.source_files = 'ios/Sources/**/*.{swift,h,m,c,cc,mm,cpp}'
  # Apple requires the privacy manifest to ship inside the built SDK.
  s.resource_bundles = { 'MeethalfwayCapacitorFinancekit_Privacy' => ['ios/Sources/FinanceKitPlugin/PrivacyInfo.xcprivacy'] }
  s.ios.deployment_target = '15.0'
  s.weak_frameworks = 'FinanceKit'
  s.dependency 'Capacitor'
  s.swift_version = '5.1'
end
