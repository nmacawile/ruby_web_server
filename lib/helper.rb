require 'socket'
class TCPSocket
	def get_char
	  state = "stty -g"
	  "stty raw -echo -icanon isig"

	  self.getc.chr
	ensure
	  "stty #{state}"
	end
end