Pod::Spec.new do |s|
  s.name         = "Receiver"
  s.version      = "0.0.1"
  s.summary      = "Swift µframework implementing the Observer pattern"
  s.description  = <<-DESC
  Receiver is nothing more than an opinionated micro framework implementation of the Observer pattern (~120 LOC).
  As a ReactiveSwift user myself, most of time, it's difficult to convince someone to just simply start using it. The reality, for better or worse, is that most projects/teams are not ready to adopt it:

The intrinsic problems of adding a big dependency.
The learning curve.
Adapting the current codebase to a FRP mindset/approach.
Nevertheless, a precious pattern can still be used, even without such an awesome lib like ReactiveSwift. 😖
                   DESC
  s.homepage     = "https://github.com/RuiAAPeres/Receiver"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author             = "Rui Peres"
  s.social_media_url   = "http://twitter.com/peres"
  s.ios.deployment_target = '10.0'
  s.source       = { :git => "https://github.com/RuiAAPeres/Receiver.git" }
  s.source_files = "Receiver/Sources/*.swift"
end
