# frozen_string_literal: true

$stdout.puts "ENV: #{ENV.fetch(ARGV[0], nil)}"
$stdout.sync

sleep 1
