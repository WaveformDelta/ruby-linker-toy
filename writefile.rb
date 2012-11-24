#=========================================================
# writefile.rb
#
# Read an object file and copy it to disk under a
# different name.  Format is:
#
#   ruby writefile.rb <inputfile> <outputfile>
#=========================================================
require 'objfile'

exit if ARGV.size < 2

ofile = ObjFile.new
ofile.loadobject(ARGV[0])
ofile.writeobject(ARGV[1])

