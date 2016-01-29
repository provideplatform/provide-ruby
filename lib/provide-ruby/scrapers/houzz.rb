module Provide
  class Houzz < Scraper
    class << self
      def category_mapping
        {
            "carpet-and-flooring" => 'flooring'
        }
      end
      
      def default_categories
        %w(carpet-and-flooring)
      end
      
      def default_zip_codes
        %w(79936 55401 60629 90650 11368 90011 11220 77084 92335 10467 77449 60617 10001 40513 30328 40201 94101 94203 98101 33101 33601 15201 02108 90210 79936 75201)
      end

      def scrape_default_zip_codes
        category_mapping.keys.each { |category| default_zip_codes.each { |zip| Resque.enqueue(ScrapeHouzzJob, zip, category) } }
      end
    end

    def initialize
      super('http://www.houzz.com')
    end

    def count(uri)
      html = fetch(uri)
      count_container = html.css('.header-2.header-dt-1.main-title').first
      count_container.text.split(' ')[0].gsub(/,/, '').to_i if count_container
    end

    def crawl(zip, category = 'carpet-and-flooring', distance = 100)
      uri = "/professionals/s/#{category}/c/#{zip}/d/#{distance}"
      count = self.count(uri)
      rpp = 15
      page = 1
      scraped_count = 0

      html = fetch(uri)
      while scraped_count < count
        puts "Scraped count == #{scraped_count} of #{count} (#{distance} from #{zip})"

        listing_container = html.css('.browseListBody').first
        listings = listing_container.css('.whiteCard.pro-card.horizontal') if listing_container
        break unless listings
        scraped_count += listings.size if listings

        listings.each do |listing_doc|
          is_sponsored = listing_doc.css('footer.text-xxs.text-sponsored.pro-sponsored').size > 0
          name = listing_doc.css('.name-info').css('a').first.text rescue '(NAME UNKNOWN)'
          phone = listing_doc.css('.pro-phone.text-m.text-dt-s').text rescue '(PHONE UNKNOWN)'
          location = listing_doc.css('.pro-info').css('.pro-meta').first.text.strip rescue '(LOCATION UNKNOWN)'
          link = listing_doc.css('.name-info').css('a').attr('href').value rescue '(HREF UNKNOWN)'

          next unless name && phone && location && link

          listing = {
              sponsors_houzz_listing: is_sponsored,
              name: name,
              vendor_type: Houzz.category_mapping[category],
              relative_location: location.split(/\t/).try(:last).try(:strip)
          }.with_indifferent_access

          contact_attributes = { name: name }.with_indifferent_access
          contact_attributes['phone'] = phone if phone && phone.length > 0

          location_parts = location.split(/\t/).try(:first)
          location_parts = location_parts.split(/ /) if location_parts
          if location_parts
            city = location_parts.shift
            while location_parts.size >= 3
              city += " #{location_parts.shift}"
            end
            contact_attributes['city'] = city.try(:strip)
            contact_attributes['city'] = contact_attributes['city'].gsub(/,/, '') if contact_attributes['city']
            contact_attributes['state'] = location_parts[0].try(:strip)
            contact_attributes['state'] = contact_attributes['state'].gsub(/,/, '') if contact_attributes['state']
            contact_attributes['zip'] = location_parts[1].try(:strip)
            contact_attributes['zip'] = contact_attributes['zip'].gsub(/,/, '') if contact_attributes['zip']

            #valid_city_state_zip = contact_attributes['city'].contact_attributes['city'].length > 0 && contact_attributes['state'].length == 2 && contact_attributes['zip'].match(/\d{5}/)
            #next unless valid_city_state_zip
          end

          if link.match(/\(href unknown\)/i).nil? && link.match(/\^javascript/i).nil?
            href = URI.parse(link) rescue nil

            response = Lead.where(houzz_href: href.to_s)
            lead = response && response.code == 200 ? (JSON.parse(response.body).try(:first) || Lead.new) : Lead.new

            refresh_details = ->() {
              response = Typhoeus::Request.get(href,
                                               headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36' })

              if response.code == 200 || response.code == 304
                houzz_profile = Nokogiri::HTML(response.body)

                street_address = houzz_profile.css('.profile-about-right').css('.info-list-label').css('.info-list-text').css('span')[4].text.split(/,/).map(&:strip) rescue nil
                street_address = nil if street_address && street_address.size > 0 && street_address[0].match(/#{contact_attributes['city']}/i)
                street_address = nil if street_address && street_address.size > 0 && street_address[0].match(/#{contact_attributes['state']}/i)
                street_address = nil if street_address && street_address.size > 0 && street_address[0].match(/#{contact_attributes['zip']}/i)
                contact_attributes['address1'] = street_address[0] if street_address && street_address.size > 0
                contact_attributes['address2'] = street_address[1] if street_address && street_address.size > 1
                contact_attributes['website'] = houzz_profile.css('.pro-contact-methods.one-line').css('a').attr('href').value rescue nil

                listing['houzz_href'] = link

                houzz_about = houzz_profile.css('.profile-about').text.gsub(/\t/, '').strip rescue nil
                houzz_about = nil if houzz_about && houzz_about.length == 0
                listing['houzz_about'] = houzz_about

                houzz_facebook_href = houzz_profile.css('a.sprite-profile-icons.f').attr('href').value rescue nil
                houzz_facebook_response = Typhoeus::Request.get(houzz_facebook_href,
                                                                headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36' }) rescue nil if houzz_facebook_href
                listing['facebook_href'] = houzz_facebook_response.headers['location'] if houzz_facebook_response && houzz_facebook_response.code == 302
                listing['facebook_href'] = nil if listing['facebook_href'] && listing['facebook_href'].length == 0

                houzz_linkedin_href = houzz_profile.css('a.sprite-profile-icons.l').attr('href').value rescue nil
                houzz_linkedin_response = Typhoeus::Request.get(houzz_linkedin_href,
                                                                headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36' }) rescue nil if houzz_linkedin_href
                listing['linkedin_href'] = houzz_linkedin_response.headers['location'] if houzz_linkedin_response && houzz_linkedin_response.code == 302
                listing['linkedin_href'] = nil if listing['linkedin_href'] && listing['linkedin_href'].length == 0

                houzz_twitter_href = houzz_profile.css('a.sprite-profile-icons.t').attr('href').value rescue nil
                houzz_twitter_response = Typhoeus::Request.get(houzz_twitter_href,
                                                               headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36' }) rescue nil if houzz_twitter_href
                listing['twitter_href'] = houzz_twitter_response.headers['location'] if houzz_twitter_response && houzz_twitter_response.code == 302
                listing['twitter_href'] = nil if listing['twitter_href'] && listing['twitter_href'].length == 0

                listing['google_plus_href'] = houzz_profile.css('a.sprite-profile-icons.g').attr('href').value rescue nil
                listing['google_plus_href'] = nil if listing['google_plus_href'] && listing['google_plus_href'].length == 0
              end

              listing['contact_attributes'] = contact_attributes
            }

            refresh_details.call

            lead.merge!(listing)
            lead.save
          end
        end

        html = fetch("#{uri}/p/#{rpp * page}")
        page += 1
      end
    end
  end
end
