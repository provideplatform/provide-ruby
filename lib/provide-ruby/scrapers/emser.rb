require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.run_server = false

module Provide
  class Emser < Scraper
    include Capybara::DSL
    
    class << self
      def scrape_default_zip_codes
        category_mapping.keys.each { |category| default_zip_codes.each { |zip| Resque.enqueue(ScrapeHouzzJob, zip, category) } }
      end
    end

    def initialize
      super('http://www.emser.com')
    end
    
    def category_ids
      %w(ceramic_porcelain natural_stone glass metal mosaic engineered_stone wall_tile)
    end

    def crawl
      category_ids.each do |category_id|
        url = "#{base_url}/index.php?id0=#{category_id}"
        visit(url)
        html = Nokogiri::HTML(page.html)
        material_anchors = html.css('div#content div#leftMenuRight div.jspContainer div.jspPane ul li a')
        material_anchors.each do |anchor|
          material_url = "#{base_url}#{anchor.attr('href')}"
          visit(material_url)
          material_html = Nokogiri::HTML(page.html)
          
          sizes_table = material_html.css('div#collectionContent div.jspPane table').last rescue nil
          standard_sizes = sizes_table.css('tbody tr td').map { |td| td.text.strip } rescue nil
          puts "URL skipped: #{material_url}" unless standard_sizes
          next unless standard_sizes
          standard_sizes.reject! { |size| !size.match(/mesh/i).nil? }
          mozaic_sizes = sizes_table.css('tbody tr td').map { |td| td.text.strip }
          mozaic_sizes.reject! { |size| size.match(/mesh/i).nil? }
          
          color_urls = []
          material_html.css('div#collectionContent div.colorsTable').first.css('tbody tr a').each do |color_anchor|
            color_urls << "#{base_url}#{color_anchor.attr('href')}"
          end
          color_urls.uniq!
          color_urls.reject! { |url| url == base_url }
          
          mozaic_urls = []
          material_html.css('div#collectionContent div.colorsTable').last.css('tbody tr a').each do |mozaic_anchor|
            mozaic_urls << "#{base_url}#{mozaic_anchor.attr('href')}"
          end if material_html.css('div#collectionContent div.colorsTable').size == 2
          mozaic_urls.uniq!
          mozaic_urls.reject! { |url| url == base_url }
          
          color_urls.each do |url|
            visit(url)
            product_html = Nokogiri::HTML(page.html)
            content = product_html.css('div#collectionContent').first
            header = content.css('div#header').first
            
            name = header.css('div.jspPane h1').first.text
            color = header.css('div.jspPane h1')[1].text rescue nil
            style = header.css('div.jspPane h2').first.text.downcase rescue nil
            
            image_url = "#{base_url}/#{product_html.css('div#collectionContent div#thumbs').first.css('img').first.attr('src')}" rescue nil
            
            sizes = []
            sizes_container = header.css('div.jspPane div').first
            sizes_container.css('li').each do |raw_size|
              sizes << { size: (raw_size.css('b').text.strip rescue nil), gtin: (raw_size.text.split(/"/).last.strip[1..raw_size.text.split(/"/).last.strip.length] rescue nil) }
            end
            
            sizes.each do |size|
              next unless size[:gtin] && size[:size]
              response = Product.where(company_id: API_COMPANY_ID, gtin: size[:gtin])
              product = response && response.code == 200 ? (Product.new(JSON.parse(response.body).try(:first)) || Product.new) : Product.new
              product[:gtin] ||= size[:gtin]
              product[:data] ||= {}
              product[:data][:manufacturer] = 'Emser'
              product[:data][:name] = "#{name}"
              product[:data][:style] = style
              product[:data][:size] = size[:size]
              product[:data][:color] = color
              product[:product_image_url] = image_url unless product[:image_url] || image_url.nil?
              product.save
            end
          end
        end
      end
    end
  end
end
