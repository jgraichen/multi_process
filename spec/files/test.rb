# frozen_string_literal: true

2.times do
  $stdout.puts "Output from #{ARGV[0]}"
  $stdout.flush
  sleep rand
end
