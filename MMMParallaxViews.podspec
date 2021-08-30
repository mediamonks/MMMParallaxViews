#
# MMMParallaxViews. Part of MMMTemple.
# Copyright (C) 2020-2021 MediaMonks. All rights reserved.
#

Pod::Spec.new do |s|

	s.name = "MMMParallaxViews"
	s.version = "0.8.2"
	s.summary = "Sticky headers/cells/footers with UITableView or UIScrollView"
	s.description = <<-END
		The idea of ParallaxViews is to bind to a UIScrollView or UITableView, and track a certain position or cell.
    The views will resize according to the scroll position, you're able to give a minimum and maximum height
    for your views, as well as a stick position.
		END
	s.homepage = "https://github.com/mediamonks/MMMParallaxViews"
	s.license = "MIT"
	s.authors = "MediaMonks"
	s.source = { :git => "https://github.com/mediamonks/MMMParallaxViews.git", :tag => s.version.to_s }

	s.platform = :ios, '11.0'

	s.swift_versions = '4.2'
	s.static_framework = true
	s.pod_target_xcconfig = {
		"DEFINES_MODULE" => "YES"
	}
  s.source_files = [  'Sources/MMMParallaxViews/**/*.swift' ]
end
