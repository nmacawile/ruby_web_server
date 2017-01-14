require 'sqlite3'
#This file generates the 'viking' table

Dir.mkdir("../db") unless Dir.exists?("../db")

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

viking = $db.execute %q(SELECT name FROM sqlite_master WHERE type='table' AND name='viking';)
create_table if viking == []


