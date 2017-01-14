class Request
	attr_reader :type, :path, :version, :headers

	def initialize(type, path, version, headers)
		@type = type
		@path = path
		@version = version
		@headers = headers
	end

	def self.parse(string)
		initial_line, *header_strings = string.scan(/^(.+)(?:\r\n)+/).flatten
		type, path, version = initial_line.split(/\s/, 3)
		
		headers = {}
		header_strings.each do |string| 
			splitted = string.split(": ", 2)
			headers[splitted[0].downcase] = splitted[1]
		end
		self.new(type, path, version, headers)
	end
end