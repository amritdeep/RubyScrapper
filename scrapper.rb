require "nokogiri"
require "open-uri"
require "json"

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
	name=detail.css('.result-name a').text.strip
	# job=detail.css('.result-suffix').text.strip
	title=detail.css('.result-suffix span').text.strip
	description=detail.css('.result-desc').text.strip
	telephone=detail.css('.result-phone').text.strip
	zip=detail.css('.result-address a').text.strip	

	## Handle profile url
	profile_url_val=detail['data-profile-url']
	profile_url="#{therapists_url}#{profile_url_val}"

	## Push to Array
	results.push(
		id: id,
		pictur_id_url: pictur_id_url,
		name: name,
		title: title,
		description: description,
		telephone: telephone,
		zip: zip,
		url : profile_url
		)



end

puts JSON.pretty_generate(results)
