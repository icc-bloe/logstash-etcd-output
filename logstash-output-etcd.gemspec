Gem::Specification.new do |s|
  s.name = 'logstash-output-etcd'
  s.version         = "0.1.0"
  s.licenses = ["Apache License (2.0)"]
  s.summary = "This output plugin enables logstash to write events to etcd."
  s.description = "This output plugin enables logstash to write events to etcd."
  s.authors = ["icc-bloe"]
  s.email = "bloe@zhaw.ch"
  s.homepage = "https://github.com/icc-bloe/logstash-output-etcd"
  s.require_paths = ["lib"]

  # Files
  s.files = `find ./lib`.split($\)
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  # s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 1.4.0", "< 2.0.0"
  s.add_runtime_dependency "logstash-codec-plain"
  s.add_runtime_dependency "etcd"
  # s.add_development_dependency "logstash-devutils"
end
