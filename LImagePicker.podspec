Pod::Spec.new do |s|
  s.name         = "LImagePicker"
  s.version      = "0.0.5"
  s.summary      = "A multi - selection, selection of original and video image selector, while there is a preview function."

  s.homepage     = "https://github.com/lessSource/LImagePicker"
  s.license      = "MIT"
  s.platform     = :ios, "10.0"
  s.author       = { "lessSource" => "2943089928@qq.com" }
  
  # s.ios.deployment_target = '10.0'


  s.source       = { :git => "https://github.com/lessSource/LImagePicker.git", :tag => "#{s.version}" }
  s.source_files  = "LImagePicker/**/*.swift"
  s.resources     = 'LImagePicker/*.bundle'
  s.swift_version = '5.0'
  s.requires_arc = true

  s.frameworks   = 'Photos'
 # s.dependency 'SDWebImage'
 

end
