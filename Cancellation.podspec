Pod::Spec.new do |spec|
  spec.name = 'Cancellation'
  spec.version = '0.1.0'
  spec.summary = 'A small Swift library which enables cancellation handling for tasks'
  spec.license = 'Apache License, Version 2.0'
  spec.homepage = 'https://github.com/couchdeveloper/Cancellation'
  spec.authors = { 'Andreas Grosam' => 'couchdeveloper@gmail.com' }
  spec.source = { :git => 'https://github.com/couchdeveloper/Cancellation.git', :tag => "#{spec.version}" }

  spec.osx.deployment_target = '10.10'
  spec.ios.deployment_target = '9.0'
  spec.tvos.deployment_target = '10.0'
  spec.watchos.deployment_target = '3.0'

  spec.source_files = "Sources/*.swift"

  spec.requires_arc = true
end
