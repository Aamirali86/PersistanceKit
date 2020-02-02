#
#  Be sure to run `pod spec lint PersistanceWrapper.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#



Pod::Spec.new do |spec|

  
  spec.name         = "PersistanceWrapper"
  spec.version      = "1.0.0"
  spec.summary      = "PersistanceKit is a wrapper around RealmSwift and CoreData to make uniform CRUD operations."
  spec.description  = "PersistanceKit is an abstract layer to fetch and persist data in a way that it is loose couple and easy to maintain and scale."

  spec.platform     = :ios, "10.0"

  spec.homepage     = "http://venturedive.com/"
  spec.license      = "MIT"
  spec.author       = { "Muhammad Aamir" => "muhammad.aamir@venturedive.com" }
  
  #spec.source      = { :git => "https://aamir-ali@bitbucket.org/vd_ajmal/persistencekit.git", :tag => "1.0.0" }
  spec.source       = { :git => "https://aamir-ali@bitbucket.org/vd_ajmal/persistencekit.git", :commit => "238bfe6" }

  
  #spec.source_files  = "PersistanceWrapper/*"
  spec.source_files  = "PersistanceWrapper/PersistanceWrapper/**/*.{h,m,swift}"
  spec.swift_version = "5.0" 
  spec.dependency 'RealmSwift'

end
