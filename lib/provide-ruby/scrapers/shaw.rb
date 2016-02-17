module Provide
  class Shaw < Scraper
    def initialize
      super('http://www.shawbuilderflooringsf.com')
    end

    def crawl
      response = fetch('/contentpage.aspx', { Id: 17264 })
      catalog_uris = response.css('#SubMenu_MenuRegion a').select { |a| a.text.match(/catalog/i) }.map { |a| a.attr('href') }

      catalog_uris.each do |catalog_uri|
        doc = visit(catalog_uri)
        initial_product_count = doc.css('td.catalogproduct').size
        
        field = find_field('MainContent_ImageCount1')
        field.find(:xpath, 'option[5]').select_option if field
        
        while doc.css('td.catalogproduct').size == initial_product_count
          doc = Nokogiri::HTML(page.html)
          sleep 1.0
          puts 'slept 1 second...'
        end
        
        products = doc.css('td.catalogproduct')
        products.each do |product|
          title_span = product.css('span')[1]
          name = title_span.children[0].text.gsub(/ by builder flooring$/i, '') rescue nil

          colors_href = product.css('a').first.attr('href') rescue nil
          colors_uri = "/#{colors_href.split(/\'/)[1]}" rescue nil

          doc = visit(colors_uri)

          colors = doc.css('#ColorList td')
          colors.each do |color_container|
            image_url = color_container.css('input[type=image]').first.attr('src') rescue nil
            next unless image_url
            color = color_container.text.strip
            gtin = "SHAW#{name}#{color}".gsub(/ /, '').upcase

            response = Product.where(company_id: API_COMPANY_ID, gtin: gtin)
            product = response && response.code == 200 ? (Product.new(JSON.parse(response.body).try(:first)) || Product.new) : Product.new
            product[:gtin] ||= gtin
            product[:data] ||= {}
            product[:data][:manufacturer] = 'Shaw'
            product[:data][:name] = name
            product[:data][:color] = color
            product[:product_image_url] = image_url unless product[:image_url] || image_url.nil?
            product.save
            
            puts "Product saved; gtin == #{product[:gtin]}"
          end
        end
      end
    end
  end
end
