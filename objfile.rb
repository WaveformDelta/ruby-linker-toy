#====================================================================
# ObjFile: Describe an object file
#
# In each of the hashes below, there may be extra fields beyond
# the ones listed
#
# An object file is a hash with these fields:
# sourcename => file or archive name, if any
# nsegs => # of segments
# nsyms => # of symbols
# nrlocs => # of relocs
# segnames => hash names to segment numbers (below)
# segrecs => [] array of segments
# symnames => hash names to symbol numbers
# symrecs => [] array of symbols (below)
# rlocrecs => [] array of relocs (below)
#
# A segment is a hash with these fields:
# segno => segment number
# base => base address as a number (not a hex string)
# size => size as a number (not a hex string)
# flags => flag characters
# data => data as a byte string (not a hex string)
#
# A symbol is a hash with these fields:
# name => symbol name
# symno => symbol number
# value => symbol value as a number (not a hex string)
# seg => segment number
# type => type
#
# A reloc is a hash with these fields:
# loc => location
# seg => segment number
# ref => reference segment or symbol number
# type => relocation type
#======================================================================
#======================================================================
# Open the String class, add hex2bin and bin2hex methods
#   see http://stackoverflow.com/questions/862140/hex-to-binary-in-ruby
#======================================================================
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
	def initialize
	  resetobject
	end
	
	#===================================================================
	# Zero out all data values
	#===================================================================
	def resetobject
	  # Zero out the element counts
	  @nsegs = @nsyms = @nrlocs = 0

	  # Create empty tables
	  @segrecs = []
	  @segnames = {}
	  @symrecs = []
	  @symnames = {}
	  @rlocrecs = []
	end

	#=================================================================
	# Load an object file and parse it into tables
	#=================================================================
	def loadobject(filename)
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
		  gather_segs(objfile)

		  # Parse symbols
		  gather_syms(objfile)

		  # Parse relocations
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
  
  #==================================================================
  # Write this object file to disk using the given name
  # If the file exists, its contents will be overwritten
  #==================================================================
  
  def writeobject(outname)
    output = File.open(outname, "w")
    
    # Write the header
    output << "LINK\n"
    output << sprintf("%d %d %d\n", @nsegs, @nsyms, @nrlocs)
    
    # Write the segment records
    @segrecs.each do |seg|
      output << sprintf("%s %02x %02x %s\n", seg[:name], seg[:loc], seg[:size], seg[:type])
    end
    
    # Write the symbol records
    @symrecs.each do |sym|
      output << sprintf("%s %02x %02x %s\n", sym[:name], sym[:value], sym[:seg], sym[:type])
    end
    
    # Write the relocation records
    @rlocrecs.each do |rloc|
      output << sprintf("%02x %02x %02x %s %s\n", rloc[:loc], rloc[:seg], rloc[:ref], rloc[:type], rloc[:extra])
    end
    
    # Write the binary data
    @segrecs.select {|seg| /P/===seg[:type]}.each do |seg|
      output << seg[:data].bin2hex + "\n"
    end
    
    output.close
  end
end
