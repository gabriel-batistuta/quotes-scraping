require 'nokogiri'
require 'httparty'

url = 'http://quotes.toscrape.com'

def extract_quotes_and_authors(url)
  response = HTTParty.get(url)
  document = Nokogiri::HTML(response.body)

  quotes = document.css('.quote span.text').map(&:text)
  authors = document.css('.quote span small.author').map(&:text)

  quotes_and_authors = quotes.zip(authors)

  quotes_and_authors.each do |quote, author|
    puts "Citação: #{quote}"
    puts "Autor: #{author}"
    puts "-" * 50

    end
  write_to_txt(quotes_and_authors, 'out/quotes.txt')
  write_to_json(quotes_and_authors, 'out/quotes.json')
end

def write_to_txt(quotes_and_authors, filename)
    File.open(filename, 'a+') do |file|
      quotes_and_authors.each do |quote, author|
        file.puts "Citação: #{quote}"
        file.puts "Autor: #{author}"
        file.puts "-" * 50
      end
    end
end

require 'json'

def write_to_json(quotes_and_authors, filename)
  data = quotes_and_authors.map { |quote, author| { 'Citação' => quote, 'Autor' => author } }

  data = { "quotes": data }

  File.open(filename, 'a+') do |file|
    file.puts JSON.pretty_generate(data)
  end
end


extract_quotes_and_authors(url)

loop do
  next_link = Nokogiri::HTML(HTTParty.get(url).body).css('.next a')
  break if next_link.empty?

  url = URI.join(url, next_link.attr('href').value).to_s
  extract_quotes_and_authors(url)
end
