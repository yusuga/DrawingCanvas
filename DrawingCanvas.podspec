Pod::Spec.new do |s|
  s.name         = "DrawingCanvas"
  s.version      = "0.0.2"
  s.summary      = "It is a touch drawing view based on image and bezier path."
  s.homepage     = "https://github.com/yusuga/DrawingCanvas"
#  s.screenshots  = ""
  s.license      = "MIT"
  s.author             = "Yu Sugawara"
  s.social_media_url   = "https://twitter.com/yusuga_"
  
  s.ios.deployment_target = "9.0"
      
  s.source       = { :git => "https://github.com/yusuga/DrawingCanvas.git", :tag => s.version.to_s }  
  s.source_files  = "DrawingCanvas/*.{swift}"
  s.requires_arc = true  
end
