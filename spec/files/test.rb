
2.times do
  $stdout.puts "Output from #{ARGV[0]}"
  $stdout.flush
  sleep rand
end
