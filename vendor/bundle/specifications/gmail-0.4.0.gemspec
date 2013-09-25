# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "gmail"
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["BehindLogic", "Chris Kowalik"]
  s.date = "2011-01-12"
  s.description = "A Rubyesque interface to Gmail, with all the tools you will need. Search, read and send multipart emails; archive, mark as read/unread, delete emails; and manage labels."
  s.email = ["chris@nu7hat.ch"]
  s.extra_rdoc_files = ["LICENSE", "README.md", "CHANGELOG.md", "TODO.md"]
  s.files = ["LICENSE", "README.md", "CHANGELOG.md", "TODO.md"]
  s.homepage = "http://github.com/nu7hatch/gmail"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "A Rubyesque interface to Gmail, with all the tools you will need."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime>, [">= 0.1"])
      s.add_runtime_dependency(%q<mail>, [">= 2.2.1"])
      s.add_runtime_dependency(%q<gmail_xoauth>, [">= 0.3.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<mocha>, [">= 0.9"])
    else
      s.add_dependency(%q<mime>, [">= 0.1"])
      s.add_dependency(%q<mail>, [">= 2.2.1"])
      s.add_dependency(%q<gmail_xoauth>, [">= 0.3.0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<mocha>, [">= 0.9"])
    end
  else
    s.add_dependency(%q<mime>, [">= 0.1"])
    s.add_dependency(%q<mail>, [">= 2.2.1"])
    s.add_dependency(%q<gmail_xoauth>, [">= 0.3.0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<mocha>, [">= 0.9"])
  end
end
