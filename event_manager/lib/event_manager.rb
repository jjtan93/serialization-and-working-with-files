require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"
@hour_count = Hash.new(0)
@wday_count = Hash.new(0)

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_homephone(homephone)
  cleaned_phone = homephone.dup
  to_sub = %w{- ( ) .}
  
  to_sub.each do |element|
    cleaned_phone.gsub!(element, "")
  end
  cleaned_phone.gsub!(" ", "")
  
  if(cleaned_phone.length == 10)
    puts "#{homephone} : #{cleaned_phone} valid!"
  elsif(cleaned_phone.length == 11 && homephone[0] == "1")
    puts "#{homephone} : #{cleaned_phone} valid!"
  else
    puts "#{homephone} : #{cleaned_phone} invalid!"
  end
end

def collect_hours(regdate)
  date_time = DateTime.strptime(regdate, "%m/%d/%Y %H:%M")
  @hour_count[date_time.hour] += 1
  @wday_count[date_time.wday] += 1
end

def find_peak_hours
  peak_hours = Hash.new 
  peak_hours = @hour_count.select {|k, v| v == @hour_count.values.max}
  peak_days = Hash.new 
  peak_days = @wday_count.select {|k, v| v == @wday_count.values.max}
  puts "Max: #{peak_hours.first[0]}, #{peak_days.first[0]}"
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  # Commented out because it will print the cleaned results to the console
  #clean_homephone(row[:homephone])
  collect_hours(row[:regdate])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
end

find_peak_hours