require 'socket'
 
host = 'localhost'     				# The web server
port = 2000                          # Default HTTP port
#path = "/index.html"          			# The file we want 

def generate_get_request(path)
	"GET #{path} HTTP/1.0\r\n"\
	"From: someone@emaildomain.com\r\n"\
	"User-Agent: HTTPTool/1.0\r\n\r\n"
end

def generate_post_request(path, json_data)
	"POST #{path} HTTP/1.0\r\n"\
	"From: frog@jmarshall.com\r\n"\
	"User-Agent: HTTPTool/1.0\r\n"\
	"Content-Type: application/x-www-form-urlencoded\r\n"\
	"Content-Length: #{json_data.size}\r\n\r\n"
end


puts "What do you want to do?: "
puts "[G] visit the viking main page"
puts "[P] register a viking for raid"
print "> "

action = gets.chomp.upcase
# This is the HTTP request we send to fetch a file
request = nil
if action == "G"
	request = generate_get_request("/index.html")
elsif action == "P"
	request = generate_post_request("/index.html")
end
#puts request

socket = TCPSocket.open(host, port)  # Connect to server

socket.print(request)               # Send request
response = socket.read              # Read complete response
puts response						# Print complete response
# Split response at first blank line into headers and body
headers,body = response.split("\r\n\r\n", 2) 
#print headers
#print body                         # And display it