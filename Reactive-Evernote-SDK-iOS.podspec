Pod::Spec.new do |s|
  s.name         = "Reactive-Evernote-SDK-iOS"
  s.version      = "0.0.5"
  s.summary      = "Reactive-Evernote-SDK-iOS."
  s.homepage     = "https://github.com/rizumita/Reactive-Evernote-SDK-iOS"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Ryoichi Izumita" => "r.izumita@caph.jp" }
  s.social_media_url   = "http://twitter.com/rizumita"
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/rizumita/Reactive-Evernote-SDK-iOS.git", :tag => "0.0.5" }
  s.source_files  = "Reactive-Evernote-SDK-iOS/*.{h,m}"
  s.requires_arc = true
  s.dependency "ReactiveCocoa", "~> 2.3"
  s.dependency "Evernote-SDK-iOS", "~> 1.3.1"
end
