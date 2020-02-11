#
# ParallaxViews.
# Copyright (C) 2020 MediaMonks. All rights reserved.
#

Pod::Spec.new do |s|

	s.name = "ParallaxViews"
	s.version = "0.1.0"
	s.summary = "Coming soon"
	s.description =  s.summary
	s.homepage = "https://github.com/mediamonks/ParallaxViews"
	s.license = "MIT"
	s.authors = "MediaMonks"
	s.source = { :git => "https://github.com/mediamonks/ParallaxViews.git", :tag => s.version.to_s }

	s.platform = :ios, '11.0'

	s.subspec 'ObjC' do |ss|
		ss.ios.source_files = [ 'Sources/ParallaxViews/*.{h,m}' ]
	end

	s.swift_versions = '4.2'
	s.static_framework = true
	s.pod_target_xcconfig = {
		"DEFINES_MODULE" => "YES"
	}
	s.subspec 'Swift' do |ss|
		ss.source_files = [ 'Sources/ParallaxViews/*.swift' ]
	end

	s.default_subspec = 'Swift'
end
