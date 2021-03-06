#
# Be sure to run `pod lib lint pushbox-sdk-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "pushbox-sdk-ios"
  s.version          = "0.1.10"
  s.summary          = "PushBoxSDK ios version. Simplified access to the PushBoxSDK api"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
    The PushBoxSDK ios SDK makes it easy to send data to the PushBoxSDK api.
                       DESC

  s.homepage         = "https://github.com/house-of-code/pushbox-sdk-ios"
  s.license          = 'MIT'
  s.author           = { "Gert Lavsen" => "gert@houseofcode.io" }
  s.source           = { :git => "https://github.com/house-of-code/pushbox-sdk-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/House_of_Code'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
end
