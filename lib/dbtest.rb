require 'sqlite3'
$db = SQLite3::Database.new("../db/dbfile")
$db.results_as_hash = true

def create_table
	puts "Creating viking table"
	$db.execute %q{
	CREATE TABLE viking (
	id integer primary key,
	name varchar(50),
	email varchar(50))
	}
end

def add_viking
	puts "Enter name:"
	name = gets.chomp
	puts "Enter email:"
	email = gets.chomp
	$db.execute("INSERT INTO viking (name, email) VALUES (?, ?)", 
		name, email)
end

def find_viking
	puts "Enter name or ID of viking to find:"
	id = gets.chomp
	viking = $db.execute("SELECT * FROM viking WHERE name = ? OR id = ?", id, id.to_i).first
	unless viking
		puts "No result found"
		return
	end
	puts %Q{Name: #{viking['name']}
Email: #{viking['email']}}
end

def all_vikings
	vikings = $db.execute("SELECT * FROM viking")

	vikings.each do |viking|
		puts "#{viking['name']} ------- #{viking['email']}"
	
	end
	#p vikings
	
end

def disconnect_and_quit
	$db.close
	puts "Bye!"
	exit
end

loop do
	puts %q{Please select an option:
	1. Create viking table
	2. Add a viking
	3. Look for a viking
	4. List all vikings
	5. Quit
}
	case gets.chomp
	when '1'
		create_table
	when '2'
		add_viking
	when '3'
		find_viking
	when '4'
		all_vikings
	when '5'
		disconnect_and_quit
	end
end