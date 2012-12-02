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

# Create sizes for each segment
textsize = datasize = bsssize = 0

inputs.each do |object|
  puts "Visiting #{object.sourcefile}..."
  
  text = object.segrecs[object.segnames[".text"]]
  textsize += text[:size] if text
  
  data = object.segrecs[object.segnames[".data"]]
  datasize += data[:size] if data
  
  bss = object.segrecs[object.segnames[".bss"]]
  bsssize += bss[:size] if bss
  
  puts "Text size: %x, Data size: %x, BSS size: %x\n" % [textsize, datasize, bsssize]
end

puts "\nSegments for output: =========================="
output.segrecs.each do |seg|
  next if seg == nil
  printf("Name: %s, Loc: %x, Size: %x, Type: %s\n", seg[:name], seg[:loc], seg[:size], seg[:type])
  printf("Data: %s...\n", seg[:data].bin2hex[0..16]) if /P/===seg[:type]
end

output.writeobject(ARGV[-1])