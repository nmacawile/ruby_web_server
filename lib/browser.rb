require 'socket'
require 'json'   

$host = 'localhost'     				
$port = 3000                     

def generate_get_request(path)
	"GET #{path} HTTP/1.1\r\n"\
	"Host: #{$host}:#{$port}\r\n"\
	"From: someone@emaildomain.com\r\n"\
	"User-Agent: HTTPTool/1.1\r\n\r\n"
end

def generate_post_request(path, json_data)
	"POST #{path} HTTP/1.1\r\n"\
	"Host: #{$host}:#{$port}\r\n"\
	"From: server@domain.com\r\n"\
	"User-Agent: HTTPTool/1.1\r\n"\
	"Content-Type: application/json\r\n"\
	"Content-Length: #{json_data.size}\r\n\r\n"\
	"#{json_data}\r\n"
end
loop {
	request = nil
	while request.nil? do
		puts "What do you want to do?: "
		puts "[M] visit the viking main page"
		puts "[U] visit a specific URL"
		puts "[R] register a viking for raid"
		puts "[V] view all registered vikings"
		puts "[Q] quit"
		print "> "
		action = gets.chomp.upcase
		case action
		when "M"
			request = generate_get_request("/index.html")
		when "U"
			puts "Type in the URL of the page you want to visit: "
			print "#{$host}:#{$port}/"
			url = gets.chomp
			request = generate_get_request("/#{url}")
		when "R"
			print "name: "
			name = gets.chomp
			print "email: "
			email = gets.chomp
			params = {}
			params['viking'] = {}
			params['viking']['name'] = name
			params['viking']['email'] = email

			request = generate_post_request("/thanks", params.to_json)	
			puts request
		when "V"
			request = generate_get_request("/vikings")
		when "Q"
			exit
		end
	end
	socket = TCPSocket.open($host, $port)

	puts "Sending request to #{$host}:#{$port}."

	socket.print(request)

	puts "Response received:"
	response = socket.read 
	puts response			

	headers, body = response.split("\r\n\r\n", 2)
}