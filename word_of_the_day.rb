#!/usr/bin/ruby2.0	

class String
	def black;          "\e[30m#{self}\e[0m" end
	def red;            "\e[31m#{self}\e[0m" end
	def green;          "\e[32m#{self}\e[0m" end
	def brown;          "\e[33m#{self}\e[0m" end
	def blue;           "\e[34m#{self}\e[0m" end
	def magenta;        "\e[35m#{self}\e[0m" end
	def cyan;           "\e[36m#{self}\e[0m" end
	def gray;           "\e[37m#{self}\e[0m" end

	def bg_black;       "\e[40m#{self}\e[0m" end
	def bg_red;         "\e[41m#{self}\e[0m" end
	def bg_green;       "\e[42m#{self}\e[0m" end
	def bg_brown;       "\e[43m#{self}\e[0m" end
	def bg_blue;        "\e[44m#{self}\e[0m" end
	def bg_magenta;     "\e[45m#{self}\e[0m" end
	def bg_cyan;        "\e[46m#{self}\e[0m" end
	def bg_gray;        "\e[47m#{self}\e[0m" end

	def bold;           "\e[1m#{self}\e[22m" end
	def italic;         "\e[3m#{self}\e[23m" end
	def underline;      "\e[4m#{self}\e[24m" end
	def blink;          "\e[5m#{self}\e[25m" end
	def reverse_color;  "\e[7m#{self}\e[27m" end
end

require 'net/http'
$DATA_FILE = '/home/burhan/.WOTD/data.csv'

if (File.exist?($DATA_FILE) and (File.readlines($DATA_FILE)).length > 0)
	data = File.readlines($DATA_FILE)[-1].split('###')
	$date = data[0]
	$word = data[1]
	$definition = data[2]
	$citation = data[3]
end

# If recird is not in data, try to get it from dictionary.com
if $date != Time.now.strftime("%d/%m/%Y")

	# Connect to word of the day page

	begin
		uri = URI.parse("http://www.dictionary.com/wordoftheday/")
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		$resp = response.code
	rescue SocketError
		$resp = -1
	end
	# Error in connecting
	if( $resp !='200')

		puts "Error Connecting to internet"

		# Print some old word if it exists
		if !File.exist?($DATA_FILE)
			puts "No Older Data Found"
		else
			num = File.readlines($DATA_FILE).length
			data = File.readlines($DATA_FILE)[Random.rand(num)].split('###')
			$date = data[0]
			$word = data[1]
			$definition = data[2]
			$citation = data[3]
		end
	else
		# store HTML page in a string 'body'
		body = response.body

		# Extract word and definition (not the cleanest way, but it works)
		$word = body.split('Definitions for <strong>',2).last[0..100].split('</strong>').first
		defin = body.split('definition-list d',2).last[0..400].split('<span>')[1]
		# puts defin.split('</span>')[0]
		if(defin.split('</span>')[0][0..3] == '<em>')
			defin = 'Slang' + defin.split('em>')[2].split('</')[0]
		else
			defin = defin.split('</')[0]
		end
		$definition = defin
		

		# Store all citation examples in an array
		ar = body.split('blockquote')[1..3]


		# Get the first quote from the array and clean it up
		q = ar[0]
		$citation = q.split('span>')[1].gsub('<strong>','').gsub('</strong>','').force_encoding('utf-8').gsub('</','')



		# Store this word with date
		# Format: date,word,definition,citation
		$date = Time.now.strftime("%d/%m/%Y")
		if File.exist?('./data')
			File.open($DATA_FILE, 'a')
		else
			File.open($DATA_FILE, 'a') {|f| f.write("#{$date}####{$word}####{$definition}####{$citation}\n") }
		end
	end
end


# DISPLAY the data
print "WORD OF THE DAY #{$date}".bold.red
puts " : #{$word.capitalize}".bold.blue
puts "    #{$definition}".bg_gray.black
puts
puts "Usage e.g.".bold.red
puts "#{$citation}"

