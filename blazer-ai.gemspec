require_relative "lib/blazer/ai/version"

Gem::Specification.new do |spec|
  spec.name = "blazer-ai"
  spec.version = Blazer::Ai::VERSION
  spec.authors = ["Kieran Klaassen"]
  spec.email = ["kieranklaassen@gmail.com"]
  spec.homepage = "https://github.com/kieranklaassen/blazer-ai"
  spec.summary = "AI-powered SQL generation for Blazer"
  spec.description = "A Rails engine that adds AI-powered natural language to SQL generation for the Blazer analytics dashboard. Uses RubyLLM to support multiple AI providers (OpenAI, Anthropic, Gemini, etc.)."
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kieranklaassen/blazer-ai"
  spec.metadata["changelog_uri"] = "https://github.com/kieranklaassen/blazer-ai/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  end

  spec.add_dependency "rails", ">= 7.1"
  spec.add_dependency "blazer", ">= 3.0"
  spec.add_dependency "ruby_llm", ">= 1.0"
end
