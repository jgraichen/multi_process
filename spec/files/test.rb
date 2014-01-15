
2.times do
  $stdout.print "Output from #{ARGV[0]}"
  $stdout.flush
  sleep rand
end
