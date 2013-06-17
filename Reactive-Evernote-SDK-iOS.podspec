Pod::Spec.new do |s|
  s.name         = "Reactive-Evernote-SDK-iOS"
  s.version      = "0.0.3"
  s.summary      = "Evernote SDK iOS with ReactiveCocoa."
  s.homepage     = "https://github.com/rizumita/Reactive-Evernote-SDK-iOS"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Ryoichi Izumita" => "r.izumita@caph.jp" }
  s.source       = { :git => "https://github.com/rizumita/Reactive-Evernote-SDK-iOS.git", :tag => "0.0.3" }
  s.platform     = :ios, '5.0'
  s.source_files = 'Reactive-Evernote-SDK-iOS/**/*.{h,m}'
  s.requires_arc = true
  s.dependency 'ReactiveCocoa'
  s.dependency 'Evernote-SDK-iOS'
end
