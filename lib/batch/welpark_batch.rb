require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'nkf'
require 'rexml/document'
require 'fastercsv'
require 'uri'
include REXML
require 'digest/md5'

class WelparkBatch
  
  @uri  = "http://www.welpark.com/store/"
  @pref_url = "http://www.welpark.com/store/"
  @geocode_url = "http://maps.google.com/maps/api/geocode/xml?sensor=false&address="
  @url_list = []
  @shop_list = ["tokyo.html", "saitama.html", "kanagawa.html", "chiba.html"]
  #@shop_list = ["shp2hyogo.html"]
  @category = "welpark"
  @file_name = "/tmp/" + @category + "_" + Time.now.strftime("%Y%m%d%H%M%S") + '.csv'
  @csv = ''
  @shop = ''

  def self.execute
    FasterCSV.open(@file_name, "w") do |@csv|
      @shop_list.each do |@shop|
        page = open(@uri + @shop)
        html = Nokogiri::HTML(page.read, nil, 'Shift_JIS')
    
        list = html.search('//table[@class="store-tbl"]//tr')
        list.each_with_index do |tr, i|
          self::scrapingShop(tr)
        end
      end
    end
  end
  
  def self.scrapingShop(tr)
    
    if tr.xpath('td').length < 4 then
      return
    end
    
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
      shop_url = @uri + @shop
    
      # 店舗名の取得
      shop_name = tr.xpath('td[1]').inner_text
    p shop_name
      td2 = tr.xpath('td[2]/text()').each_with_index { |element, idx| 
        case idx
          when 0
            address = element.inner_text.gsub(/〒[0-9\-]*/, '').strip.gsub(/[　]*/, '')
          when 1
           tel      = element.inner_text.gsub(/TEL[:：]{1}([0-9\-]*)(.*)/, '\1').strip.gsub(/[　]*/, '')
        end
      }
      business_hours = tr.xpath('td[4]').inner_text.gsub(/[ ]*【営業時間】[ ]*/, '').gsub(/\n/, '<br />').strip
    p address
    p tel
    p business_hours
      
      # 緯度経度の取得
      latlng = self::getLatLng(address)
      lat = latlng[0]
      lng = latlng[1]
    
    p lat
    p lng
    
      uid = Digest::MD5.new.update(shop_name)
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