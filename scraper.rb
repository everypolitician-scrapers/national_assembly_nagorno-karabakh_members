# #!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri/cached'

OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  curr_party = ''
  noko.css('div.contetn-ceter div p').each do |para|
    party = para.css('b', 'strong').text.to_s
    if party.index('the electoral list of the') then
        party = party.gsub(/.*the electoral list of the/, '')
        party = party.gsub(/^\s*party\s*/, '')
        party = party.gsub(/[”“″]/, '')
        party = party.tidy
        curr_party = party
        next
    end
    if curr_party != '' then
        possible_name = para.text.to_s.tidy
        if possible_name.match(/^\d+\./) then
            name = possible_name.gsub(/^\d+\.\s*/, '').tidy

            data = {
                name: name,
                party: curr_party,
                source: url,
            }

            ScraperWiki.save_sqlite([:name, :party], data)
        end
    end
  end
end

scrape_list('http://cecnkr.am/%D5%B6%D5%B8%D6%80%D5%A8%D5%B6%D5%BF%D5%AB%D6%80-%D5%A1%D5%A6%D5%A3%D5%A1%D5%B5%D5%AB%D5%B6-%D5%AA%D5%B8%D5%B2%D5%B8%D5%BE%D5%AB-%D5%BA%D5%A1%D5%BF%D5%A3%D5%A1%D5%B4%D5%A1%D5%BE%D5%B8%D6%80%D5%B6/?lang=en')
