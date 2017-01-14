require 'socket'        
require 'json'
require 'uri'
require 'sqlite3'
require './request'
require './helper'


server = TCPServer.open(3000)  	

$routes = 
{
	get: {
		"/" => "/index.html",
		"/index.html" => "/index.html",
		"/register" => "/register.html",
		"/vikings" => "/vikings.html"
	},
	post: {
		"/thanks" => "/thanks.html"
	}
}

$formatting = 
{ 
	"viking" => lambda { |name, email| "<li>#{name} (#{email})</li>" }
}

def format(params)
	schema = params.keys.first
	values = params[schema].values
	formatted = values.each_slice(values.count).map(&$formatting[schema]).join
	formatted
end

$db = SQLite3::Database.new("../db/dbfile")
$db.results_as_hash = true

$data = 
{	
	"/vikings" => lambda { 
		data = $db.execute("SELECT * FROM viking").map do |tuple|
			format({'viking' => {"name" => tuple["name"], "email" => tuple["email"]}})
		end.join
	}
}

$save = {
	"/thanks" => lambda { |params|
		$db.execute("INSERT INTO viking (name, email) VALUES (?, ?)", 
		params["viking"]["name"], params["viking"]["email"])
	}
}

def generate_response(method, path, params = nil)
	status = $routes[method].key?(path) ? "HTTP/1.1 200 OK\r\n" : "HTTP/1.1 404 Not Found\r\n"
	file_address = $routes[method].key?(path) ? "..#{$routes[method].fetch(path)}" : "../error404.html"

	page = File.read(file_address)
	page.gsub!(/<%=\s*yield\s*%>/, format(params)) if method == :post

	$save[path].call(params) if method == :post && $save.key?(path)

	page.gsub!(/<%=\s*yield\s*%>/, $data[path].call) if $data.key?(path)

	response = "Date: #{Time.now.ctime}\r\nContent-Type: text/html\r\nContent-Length: #{page.size}\r\n\r\n"	

	response.prepend status
	response += page
end

def parse_data(data)
	params = {}
	if data =~ /^{.+}$/
  		params = JSON.parse(data)
  	else
		schema = data.scan(/^\w+/).first
		splitted = data.split("&")
		splitted.map! { |string| URI.unescape string }

		params[schema] = {}
		splitted.each do |pair|
		  	key = pair.scan(/(?:\[)(.+)(?:\])/).flatten.first
			value = pair.scan(/(?:=)(.*)/).flatten.first
			params[schema][key] = value
		end
  	end
  	params
end

loop {                        	 

	puts "Awaiting connection..."
  	client = server.accept       

  	request_string = ""
  	while request_line = client.gets and request_line !~ /^\s+$/
  		request_string += request_line 
  	end
	
	unless request_string == ""
		puts "Request received."
	  	request = Request.parse(request_string)

	  	puts "method: #{request.type}",
	  		 "path: #{request.path}",
	  		 "version: #{request.version}",
	  		 "headers: "
	  	request.headers.each { |k, v| puts "	#{k} => #{v}" }

	  	data = ""
	  	params = {}
	  	
	  	if request.type == "POST"
	  		content_length = request.headers['content-length'].to_i
		  	while line = client.get_char
		    	data += line
		    	break if data.size == content_length
		  	end
		  	params = parse_data(data)
		  	puts "data: #{data}"
	  	end  	

		client.print generate_response(request.type.downcase!.to_sym, request.path, params)
		puts "Response has been sent."
	end	
  	client.close			    
}