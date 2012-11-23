#===================================================================
# Open the String class, add hex2bin and bin2hex methods
#   see http://stackoverflow.com/questions/862140/hex-to-binary-in-ruby
#===================================================================
class String
	
	def hex2bin
		s = self
		raise "Not a vaild hex string" unless (s =~ /^[\da-fA-F]+$/)
		raise "Invalid hex string length" unless ((s.length & 1) == 0)
		s.scan(/../).map{|b| b.to_i(16)}.pack('C*')
	end
	
	def bin2hex
		self.unpack('C*').map{|b| "%02X" % b}.join('')
	end
end

class ObjFile
	#===================================================================
	# Public variables
	#===================================================================
	attr_accessor :nsegs
	attr_accessor :nsyms
	attr_accessor :nrlocs
	attr_accessor :segrecs
	attr_accessor :segnames
	attr_accessor :symrecs
	attr_accessor :symnames
	attr_accessor :rlocrecs
  attr_accessor :sourcefile
	
	#===================================================================
	# Give an filename, load parse an object file
	#===================================================================
	
	def initialize(filename)
		begin
      @sourcefile = filename
      
			File.open(filename, "r") do |objfile|
				unless getl(objfile) == "LINK"
					puts "Invalid file format: " + filename
					return nil
				end

				# Read header info
				@nsegs, @nsyms, @nrlocs = getl(objfile).split(' ').collect {|x| x.to_i}
				
				# Parse segs
				@segrecs = [], @segnames = {}
				gather_segs(objfile)
				
				# Parse symbols
				@symrecs = [], @symnames = {}
				gather_syms(objfile)
				
				# Parse relocations
				@rlocrecs = []
				gather_rlocs(objfile)
				
				# Slurp in data
				@segrecs.select {|seg| /P/===seg[:type]}.each do |seg|
					seg[:data] = getl(objfile).hex2bin
				end

			end
		rescue
			puts "Could not open object file: " + filename
		end
	end

	#===================================================================
	# Get a line from the object file, ignoring comments and whitespace
	#===================================================================

	def getl(fh)
		fh.each do |line|
			next if /^#/===line					# comment
			next if /^[ \t]*$/===line		# whitespace
			return line.chomp
		end
	end
	
	#===================================================================
	# Collect a hash of segments for the object file
	#===================================================================
	
	def gather_segs(fh)
		(0...@nsegs).each do |segnum|
			name, loc, size, type = getl(fh).split(' ')
					
			@segrecs[segnum] = build_segrec(segnum, name, loc.hex, size.hex, type)
			@segnames[name] = segnum
		end
	end
	
	#===================================================================
	# Build a segment record from components
	#   num  = integer segment number (starts at index 0)
	#   name = string name of segment
	#   loc  = integer starting location of this segment
	#   size = integer size of segment in bytes
	#   type = string attributes for this segment
	#   data = packed byte array of data for this segment (if present)
	#===================================================================
	
	def build_segrec(num, name, loc, size, type, data=nil)
		seg = Hash.new
		
		seg[:segno] = num
		seg[:name] = name
		seg[:loc]  = loc
		seg[:size] = size
		seg[:type] = type
		seg[:data] = data unless data == nil
		return seg
	end
	
	#===================================================================
	# Collect a hash of symbols for the object file
	#===================================================================
	
	def gather_syms(fh)
		(0...@nsyms).each do |symnum|
			name, value, seg, type = getl(fh).split(' ')

			@symrecs[symnum] = build_symrec(symnum, name, value.hex, seg.hex, type)
			@symnames[name] = symnum
		end
	end
	
	#===================================================================
	# Build a symbol record from components
	#   num   = integer symbol number (starts at index 0)
	#   name  = string name of symbol
	#   value = integer value of symbol
	#   seg   = integer segment number where symbol is located
	#   type  = string attributes for this symbol
	#===================================================================
	
	def build_symrec(num, name, value, seg, type)
		sym = Hash.new
		
		sym[:symno] = num
		sym[:name]  = name
		sym[:value] = value
		sym[:seg]   = seg
		sym[:type]  = type
		return sym
	end
	
	#===================================================================
	# Collect a hash of relocations for the object file
	#===================================================================
	
	def gather_rlocs(fh)
		(0...@nrlocs).each do |rlocnum|
			loc, seg, ref, type, extra = getl(fh).split(' ', 5)
			
			@rlocrecs[rlocnum] = build_rlocrec(loc.hex, seg.hex, ref.hex, type, extra)
		end
	end
	
	#==================================================================
	# Build a relocation record from components
	#   loc   = integer location in target segment
	#   seg   = integer number of target segment
	#   ref   = integer number of segment rloc refers to
	#   type  = string attributes for this rloc
	#   extra = string extra info, depens on type
	#==================================================================
	
	def build_rlocrec(loc, seg, ref, type, extra=nil)
	  rloc = Hash.new
	  
	  rloc[:loc]   = loc
	  rloc[:seg]   = seg
	  rloc[:ref]   = ref
	  rloc[:type]  = type
	  rloc[:extra] = extra  # Always include extra, even if it's nil
	  return rloc
	end
end

ofile = ObjFile.new("ch4main.lk")

puts ofile.sourcefile + " ==========================="
printf("%d segments, %d symbols, %d relocations\n", ofile.nsegs, ofile.nsyms, ofile.nrlocs)

puts "\nSegments: =========================="
ofile.segrecs.each do |seg|
  printf("Name: %s, Loc: %x, Size: %x, Type: %s\n", seg[:name], seg[:loc], seg[:size], seg[:type])
end

puts "\nSymbols: ==========================="
ofile.symrecs.each do |sym|
  printf("Name: %s, Value: %x, Segment num: %d, Type: %s\n", sym[:name], sym[:value], sym[:seg], sym[:type])
end

puts "\nRelocations: ======================="
ofile.rlocrecs.each do |rloc|
  printf("Location: %x, Target segment num: %d, Refers to: %d, Type: %s\n", rloc[:loc], rloc[:seg], rloc[:ref], rloc[:type])
end
