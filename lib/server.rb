require 'socket'               	# Get sockets from stdlib

server = TCPServer.open(2000)  	# Socket to listen on port 2000

def generate_get_response(path)
	file = File.new("..#{path}")
	response = 
		"HTTP/1.0 200 OK\r\n"\
		"Date: #{Time.now.ctime}\r\n"\
		"Content-Type: text/html\r\n"\
		"Content-Length: #{file.size}\r\n\r\n"	
	file.readlines.each { |line| response += line }
	file.close
	response += "\r\n\r\n"
	response
end

def generate_post_response(path, data)

end

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
			headers[splitted[0]] = splitted[1]
		end
		self.new(type, path, version, headers)
	end
end

loop {                        	 # Servers run forever
  	client = server.accept       # Wait for a client to connect

  	request_string = ""

  	while request_line = client.gets and request_line !~ /^\s+$/
  		request_string += request_line # Prints whatever the client enters on the server's output
  	end

  	#puts request_string

  	request = Request.parse(request_string)
  	puts "type: #{request.type}"
  	puts "path: #{request.path}"
  	puts "version: #{request.version}"
  	puts "headers: #{request.headers}"



 	client.print generate_get_response("/index.html")

  	client.close			      # Disconnect from the client
}