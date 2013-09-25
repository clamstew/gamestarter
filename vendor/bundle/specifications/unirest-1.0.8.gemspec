# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "unirest"
  s.version = "1.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mashape"]
  s.date = "2013-04-23"
  s.description = "Unirest is a set of lightweight HTTP libraries available in PHP, Ruby, Python, Java, Objective-C."
  s.email = "support@mashape.com"
  s.homepage = "https://unirest.io"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Unirest, the lightweight HTTP library"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<addressable>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<addressable>, [">= 0"])
  end
end
