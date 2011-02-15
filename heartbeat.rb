#!/usr/bin/env ruby -wKU

#include
require 'net/http'
require 'net/smtp'

#options
debug = true

send_email = false

email_from = 'from@yourdomain.com'
email_to = 'to@yourdomain.com'
smtp_server = 'smtp.rdslink.ro'

#open websites file
File.open('websites.txt', 'r') do |line|  

	#for every website
	while website = line.gets

		puts "\n\nVerifying #{website}" unless not debug

		#check for comment || temporary disabled
		if (website[0..0] == '#')
			puts "skipping.." unless not debug
		else
			#add http://
			website.insert(0, "http://")

			#fetch HTTP_RESPONSE from the current website
			begin
				response = Net::HTTP.get_response(URI.parse(website.to_s))
				code = response.code
				message =  response.message
			
			rescue Exception => e
				puts "Exception occured: #{e.message}" unless not debug
				code = 600
				message = e.message
			end

			puts "Response: #{code} - #{message}" unless not debug

			#check for 2xx or 3xx status
			unless(code =~ /2|3\d{2}/ ) then

				#email body
				message = "From: #{email_from}\nTo: #{email_to}\nSubject: #{website} Unavailable\n\n#{website} : #{code} - #{message}\\n\n"

				#send email
				unless not send_email then
					begin
						Net::SMTP.start(smtp_server, 25) do |smtp|
							smtp.send_message(message, email_from, email_to)
						end
					rescue Exception => e
						puts "Fatal exception occured: " + e
					end
				end

			end #end check status code

		end	#end skipped line	
		
	end  #end each website

 end #end file open