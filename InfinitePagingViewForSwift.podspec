Pod::Spec.new do |s|
  s.name             = "InfinitePagingViewForSwift"
  s.version          = "0.1.0"
  s.summary          = "Infinite ScrollView"
  s.description      = <<-DESC
                        "InfinitePagingView is a subclass of UIView. It contains an endlessly scrollable UIScrollView."
                       DESC
  s.homepage         = "https://github.com/nakazy/InfinitePagingViewForSwift"
  s.license          = 'MIT'
  s.author           = { "nakazy" => "s.nakajima0523@gmail.com" }
  s.source           = { :git => "https://github.com/nakazy/InfinitePagingViewForSwift.git", :tag => "0.1.0" }
  s.social_media_url = 'https://twitter.com/Shachikusky'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'InfinitePagingViewForSwift' => ['Pod/Assets/*.png']
  }
end
