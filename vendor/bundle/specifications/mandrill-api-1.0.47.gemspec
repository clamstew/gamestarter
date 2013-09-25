# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mandrill-api"
  s.version = "1.0.47"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mandrill Devs"]
  s.date = "2013-09-13"
  s.description = "A Ruby API library for the Mandrill email as a service platform."
  s.email = "community@mandrill.com"
  s.homepage = "https://bitbucket.org/mailchimp/mandrill-api-ruby/"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "A Ruby API library for the Mandrill email as a service platform."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, ["< 2.0", ">= 1.7.7"])
      s.add_runtime_dependency(%q<excon>, ["< 1.0", ">= 0.16.0"])
    else
      s.add_dependency(%q<json>, ["< 2.0", ">= 1.7.7"])
      s.add_dependency(%q<excon>, ["< 1.0", ">= 0.16.0"])
    end
  else
    s.add_dependency(%q<json>, ["< 2.0", ">= 1.7.7"])
    s.add_dependency(%q<excon>, ["< 1.0", ">= 0.16.0"])
  end
end
