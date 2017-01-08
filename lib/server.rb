require 'socket'               	# Get sockets from stdlib

server = TCPServer.open(2000)  	# Socket to listen on port 2000

loop {                        	 # Servers run forever
  	client = server.accept       # Wait for a client to connect

  	while line = client.gets and line !~ /^\s+$/
  		puts line # Prints whatever the client enters on the server's output
  	end

	file = File.new("../index.html")

 	client.print 	"HTTP/1.0 200 OK\r\n"\
					"Date: #{Time.now.ctime}\r\n"\
					"Content-Type: text/html\r\n"\
					"Content-Length: #{file.size}\r\n\r\n"

	file.readlines.each { |line| client.write line }
	client.write "\r\n\r\n"

 	file.close
  	client.close			      # Disconnect from the client
}