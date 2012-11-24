#=========================================================
# readfile.rb
#
# Read an object file and print out information about it.
#=========================================================
require 'objfile'

ofile = ObjFile.new("obj/main.lk")

puts ofile.sourcefile + " ==========================="
printf("%d segments, %d symbols, %d relocations\n", ofile.nsegs, ofile.nsyms, ofile.nrlocs)

puts "\nSegments: =========================="
ofile.segrecs.each do |seg|
  printf("Name: %s, Loc: %x, Size: %x, Type: %s\n", seg[:name], seg[:loc], seg[:size], seg[:type])
  printf("Data: %s...\n", seg[:data].bin2hex[0..16]) if /P/===seg[:type]
end

puts "\nSymbols: ==========================="
ofile.symrecs.each do |sym|
  printf("Name: %s, Value: %x, Segment num: %d, Type: %s\n", sym[:name], sym[:value], sym[:seg], sym[:type])
end

puts "\nRelocations: ======================="
ofile.rlocrecs.each do |rloc|
  printf("Location: %x, Target segment num: %d, Refers to: %d, Type: %s\n", rloc[:loc], rloc[:seg], rloc[:ref], rloc[:type])
end
