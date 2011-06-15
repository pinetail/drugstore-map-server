require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'nkf'
require 'rexml/document'
require 'fastercsv'
require 'uri'
include REXML

class DaikokuBatch
  
  @uri  = "http://www.daikokudrug.com/shop/shp/"
  @pref_url = "http://www.daikokudrug.com/shop/shp/"
  @geocode_url = "http://maps.google.com/maps/api/geocode/xml?sensor=false&address="
  @url_list = []
  @shop_list = ["shp5hok_toh.html", "shp4kant.html", "shp6hoku.html", "shp7tokai.html", "shp1osaka.html", "shp2hyogo.html", "shp3kyna.html", "shp8chg_skk.html", "shp9ky_ok.html"]
  #@shop_list = ["shp2hyogo.html"]
  @category = "daikokudrug"
  @file_name = "/tmp/" + @category + "_" + Time.now.strftime("%Y%m%d%H%M%S") + '.csv'
  @csv = ''

  def self.execute
    FasterCSV.open(@file_name, "w") do |@csv|
      @shop_list.each do |shop|
        page = open(@uri + shop)
        if shop == 'shp2hyogo.html' then
          html = Nokogiri::HTML(page.read, nil, 'utf-8')
        else
          html = Nokogiri::HTML(page.read, nil, 'Shift_JIS')
        end
    
        list = html.search('//div[@id="shp_list"]//a')
        list.each_with_index do |a, i|
          href = a.xpath("@href").to_s
    
          if href != '' && @url_list.index(href).nil? then
            puts href
            @url_list.push(href)
            self::scrapingShop(href)
            sleep 5
          end
        end
      end
    end
  end
  
  def self.scrapingShop(shop_html)
    p @uri + shop_html
      shop_url = @uri + shop_html
      page = open(@uri + shop_html)
      html = Nokogiri::HTML(NKF.nkf('-wS', page.read), nil, "UTF-8")
      shop_name = ''
      address = ''
      tel = ''
      access = ''
      business_hours = ''
      holiday = ''
      lat = ''
      lng = ''
      sale_name = ''
      sale_date = ''
    
      # 店舗名の取得
      shop_name = html.search('//div[@id="shp"]/h2/text()').to_s.gsub(/[　]*/, '')
    
      # 店舗情報の取得
      list = html.search('//div[@id="shp_shp"]//tr')
      list.each_with_index do |tr, i|
        label = tr.xpath('th').inner_text
    
        case label
        when '住所'
          address        = tr.xpath('td').inner_text.gsub(/〒[0-9\-]*/, '').strip.gsub(/\n/, '<br />')
        when 'TEL / FAX'
          tel            = tr.xpath('td').inner_text.strip.gsub(/\n/, '<br />')
        when 'アクセス'
          access         = tr.xpath('td').inner_text.strip
        when "営業時間"
          business_hours = tr.xpath('td').inner_text.gsub(/\n/, '<br />')
        when '定休日'
          holiday        = tr.xpath('td').inner_text.strip.gsub(/\n/, '<br />')
        end
      end
    p address
      
      # 緯度経度の取得
      latlng = self::getLatLng(address)
      lat = latlng[0]
      lng = latlng[1]
    
    p lat
    p lng
    
      # お得なセール日
      name_arr = []
      date_arr = []
      info_sale = html.search('//div[@id="info_sale"]//tr')
      info_sale.each_with_index do |tr, i|
        tr.xpath('th/text()').each do |row|
          name_arr.push(row.to_s.strip.gsub(/\n/, ''))
        end
        tr.xpath('td/text()').each do |row|
          date_arr.push(row.to_s.strip.gsub(/\n/, ''))
        end
        sale_name = name_arr.join('<br />')
        sale_date = date_arr.join('<br />')
    
      end
    
      uid = shop_html.gsub(/\.html/, '')
      @csv << ["#{uid}", "#{@category}", "#{shop_name}", "#{address}", "#{tel}", "#{access}", "#{business_hours}", "#{holiday}", "#{lat}", "#{lng}", "#{shop_url}", "", "#{sale_name}", "#{sale_date}", "", "", ""]

  end

  def self.getLatLng(address)
    page = open(@geocode_url + URI.encode(address.gsub(/<br \/>/, ' ')))
    html = Nokogiri::HTML(page.read, nil, "UTF-8")
    
    lat = html.search("//geometry/location/lat").inner_text
    lng = html.search("//geometry/location/lng").inner_text

    return [lat, lng]
  end
end