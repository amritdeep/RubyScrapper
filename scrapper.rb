require "nokogiri"
require "open-uri"
require "json"
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

	qualifications=profile.xpath('//div[@class="section profile-qualifications"]')

	## Handle Number of year
	year=qualifications.css('.section-content li[1]').text.strip
	qualifications_years_in_practice=year.split("Years in Practice: ").last

	## Handle School name
	schoool=qualifications.css('.section-content li[2]').text.strip
	qualifications_school_name=schoool.split("School: ").last

	## Handle Year Graduated
	graduated=qualifications.css('.section-content li[3]').text.strip
	qualifications_year_graduated=graduated.split("Year Graduated: ").last

	## Handle License Number
	license_state=qualifications.css('.section-content li[4]').text.strip
	qualifications_license_no=license_state.split("License No. and State: ").last.to_i

	## Handle State
	# state=qualifications.css('.section-content li[5]').text.strip
	# qualifications_State=state.split("")

	## Handle Finances
	finances=profile.xpath('//div[@class="section profile-finances"]')
	scale=finances.css('.section-content li[1]').text.strip
	sliding_scale=scale.split("Sliding Scale: ").last


	# ## Handle Additional Credentials
	credentials=profile.xpath('//div[@class="section profile-additionalcredentials"]')

	membership_val=credentials.css('.section-content li[1]').text.strip
	membership=membership_val.split("Membership: ").last

	member_dt=credentials.css('.section-content li[2]').text.strip
	member_since=member_dt.split("Member Since: ").last



	## Added to Array
	results.push(
		id: id,
		url: profile_url,
		title: title,
		name: name,
		pictur_id_url: pictur_id_url,
		# image_name:,
		# website_url:,
		verified_by_psychology_today: verified_by_psychology_today,
		description: description,
		qualifications_years_in_practice: qualifications_years_in_practice,
		qualifications_school_name: qualifications_school_name,
		qualifications_year_graduated: qualifications_year_graduated,
		qualifications_license_no: qualifications_license_no,
		# qualifications_State: qualifications_State,
		sliding_scale: sliding_scale,
		additional_membership: membership,
		additional_member_since: member_since
		)


	CSV.open("output.csv", "a+") do |csv|
		csv << results
	end

	CSV.foreach("output.csv") do |row|
		puts row 
	end

end

output=JSON.pretty_generate(results)

File.open("output.json", "w") { |file| file.write(output)  }