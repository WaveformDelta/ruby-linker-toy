#=========================================================
# linkfiles.rb
#
# Read several object files and combine them into an
# output file, allocating storage appropriately.
# Call as:
#
#   ruby linkfiles.rb [<inputfile>...] <outputfile>
#=========================================================
require 'objfile'

exit if ARGV.size < 2

inputs = []

for i in (0...ARGV.size-1)
  puts "Creating ObjFile for " + ARGV[i]
  ofile = ObjFile.new
  ofile.loadobject(ARGV[i])
  inputs[i] = ofile
end

output = ObjFile.new

inputs.each do |object|
  object.segrecs.each do |seg|
	output.segrecs << seg
  end
end

puts "\nSegments for output: =========================="
output.segrecs.each do |seg|
  next if seg == nil
  printf("Name: %s, Loc: %x, Size: %x, Type: %s\n", seg[:name], seg[:loc], seg[:size], seg[:type])
  printf("Data: %s...\n", seg[:data].bin2hex[0..16]) if /P/===seg[:type]
end

output.writeobject(ARGV[-1])