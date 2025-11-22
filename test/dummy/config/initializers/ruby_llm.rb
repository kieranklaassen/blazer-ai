RubyLLM.configure do |c|
  c.openai_api_key = ENV["OPENAI_API_KEY"]   # required for o4‑mini / GPT‑4o
  # Add other provider keys as needed…
end
