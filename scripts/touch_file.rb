`touch /var/www/apps/post_hook/current/tmp/github.txt`
ARGV.each do|a|
  `echo "#{a}" > tmp/github.txt`
end
