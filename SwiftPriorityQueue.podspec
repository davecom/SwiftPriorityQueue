Pod::Spec.new do |s|
  s.name             = 'SwiftPriorityQueue'
  s.version          = '1.0.2'
  s.license          = 'MIT'
  s.summary          = 'A Generic Priority Queue in Pure Swift'
  s.homepage         = 'https://github.com/davecom/SwiftPriorityQueue'
  s.social_media_url = 'https://twitter.com/davekopec'
  s.authors          = { 'David Kopec' => 'david@oaksnow.com' }
  s.source           = { :git => 'https://github.com/davecom/SwiftPriorityQueue.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.source_files = 'SwiftPriorityQueue/SwiftPriorityQueue.swift'
  s.requires_arc = true
end
