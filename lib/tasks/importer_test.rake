require "rake/testtask"

namespace :test do
  Rake::TestTask.new(:importer) do |task|
    task.libs << "test"
    task.libs << "engines/importer/test"
    task.pattern = "engines/importer/test/**/*_test.rb"
    task.verbose = false
  end
end

task test: "test:importer"
