Pod::Spec.new do |spec|
  spec.name = 'Cancellation'
  spec.version = '0.7.0'
  spec.summary = 'Cancellation Handling for Asynchronous Tasks in Swift'
  spec.license = 'Apache License, Version 2.0'
  spec.homepage = 'https://github.com/couchdeveloper/Cancellation'
  spec.authors = { 'Andreas Grosam' => 'couchdeveloper@gmail.com' }
  spec.source = { :git => 'https://github.com/couchdeveloper/Cancellation.git', :tag => "#{spec.version}" }

  spec.osx.deployment_target = '10.10'
  spec.ios.deployment_target = '9.3'
  spec.tvos.deployment_target = '10.2'
  spec.watchos.deployment_target = '3.2'

  spec.source_files = "Sources/*.swift"

  spec.requires_arc = true

  spec.swift_version = ['4.2', '5']
end
