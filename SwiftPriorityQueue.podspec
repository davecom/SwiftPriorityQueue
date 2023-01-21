Pod::Spec.new do |s|
  s.name             = 'SwiftPriorityQueue'
  s.version          = '1.4.0'
  s.license          = 'MIT'
  s.summary          = 'A Generic Priority Queue in Pure Swift'
  s.homepage         = 'https://github.com/davecom/SwiftPriorityQueue'
  s.social_media_url = 'https://twitter.com/davekopec'
  s.authors          = { 'David Kopec' => 'david@oaksnow.com' }
  s.source           = { :git => 'https://github.com/davecom/SwiftPriorityQueue.git', :tag => s.version }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'
  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7']
  s.source_files = 'Sources/SwiftPriorityQueue/SwiftPriorityQueue.swift'
  s.requires_arc = true
end
