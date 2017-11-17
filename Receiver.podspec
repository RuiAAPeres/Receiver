Pod::Spec.new do |s|
  s.name         = "Receiver"
  s.version      = "0.0.1"
  s.summary      = "Swift µframework implementing the Observer pattern"
  s.description  = <<-DESC
  Receiver is nothing more than an opinionated micro framework implementation of the Observer pattern.
                   DESC
  s.homepage     = "https://github.com/RuiAAPeres/Receiver"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author             = "Rui Peres"
  s.social_media_url   = "http://twitter.com/peres"
  s.ios.deployment_target = '10.0'
  s.source       = { :git => "https://github.com/RuiAAPeres/Receiver.git" }
  s.source_files = "Receiver/Sources/*.swift"
end
