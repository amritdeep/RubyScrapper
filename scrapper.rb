require "nokogiri"
require "open-uri"
require "json"
require "pry"
require "csv"

# puts "Enter city or zip ="
# city_zip=gets.chomp
city_zip="new york"

city_zip=city_zip.sub(/ /, '+') if city_zip.match(/\s/)

puts "#{city_zip}"


# href="/rms/state/#{city_zip}.html"
# country_href="https://therapi`sts.psychologytoday.com/rms/county/#{city_zip}/#{city_zip}.html"
therapists_url="https://therapists.psychologytoday.com"
state_href="https://therapists.psychologytoday.com/rms/state/#{city_zip}/#{city_zip}.html"
puts "#{state_href}"

url=Nokogiri::HTML(open(state_href))
data=url.xpath('//div[@id="results-right"]')
detail=data.xpath('//div[@class="row-fluid result-row"]')

results = []

detail.each do |detail|
	id=detail['data-profid']
	pictur_id_url= detail.css('.result-photo img').attr('src').value
	# pictur_id_url=detail.css('.result-photo a')
	
	name=detail.css('.result-name a').text.strip

	## Handle teh verified by Psychology Today
	verified_value=detail.css('.result-title a').attr('title').value
	verifed=verified_value.split("#{name} is ").last
	verified_by_psychology_today="Yes" if verifed == "verified by Psychology Today"

	# job=detail.css('.result-suffix').text.strip
	title=detail.css('.result-suffix span').text.strip
	description=detail.css('.result-desc').text.strip
	telephone=detail.css('.result-phone').text.strip
	zip=detail.css('.result-address a').text.strip

	## Handle profile url
	profile_url_val=detail['data-profile-url']
	profile_url="#{therapists_url}#{profile_url_val}"

	## Handle qualifications
	profile=Nokogiri::HTML(open(profile_url))

	profile_name=profile.xpath('//div[@class="section profile-name"]/h1').text
	profille_title=profile.xpath('//div[@class="profile-title"]/h2').text.split("\n").join
	profile_about=profile.xpath('//div[@class="section profile-personalstatement"]').text.split("\n").join

	results.push(profile_url: profile_url, profille_title: profille_title,  profile_name: profile_name,  profile_about: profile_about)
end

puts results

File.delete("output.csv")
File.delete("output.json")

CSV.open("output.csv", "a+") do |csv|
	results.each { |results| csv << [results[:profile_url], results[:profille_title], results[:profile_name], results[:profile_about]] }
end

# CSV.foreach("output.csv") do |row|
# 	puts row 
# end

output=JSON.pretty_generate(results)

File.open("output.json", "w") { |file| file.write(output)  }