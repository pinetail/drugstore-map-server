require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'nkf'
require 'rexml/document'
require 'fastercsv'
require 'uri'
include REXML

class MidoriyakuhinBatch
  
  @pref_url    = "http://www.midoriyakuhin.co.jp/guide/"
  @url         = @pref_url
  @geocode_url = "http://maps.google.com/maps/api/geocode/xml?sensor=false&address="
  @url_list    = []
  @shop_list  = ["", "hukuoka.html", "kumamoto.html", "saga.html", "nagasaki.html", "miyazaki.html", "ooita.html", "okinawa.html"]
  #@shop_list   = ["hukuoka.html"]
  @category    = "midoriyakuhin"
  @file_name   = "/tmp/" + @category + "_" + Time.now.strftime("%Y%m%d%H%M%S") + '.csv'
  @csv         = ''
  @area        = ''
  @counter     = 1

  def self.execute
    FasterCSV.open(@file_name, "w") do |@csv|
      @shop_list.each do |shop|
        @counter = 1
        @area = shop
        @url = @pref_url + shop
        page = open(@pref_url + shop)
        html = Nokogiri::HTML(NKF.nkf("-wS", page.read), nil, 'UTF-8')

        list = html.search('//body/div/table//table//table//tr')
        list.each_with_index do |tr, i|
        
          if (i > 1) then
            self::scrapingShop(tr)
            @counter = @counter + 1
            sleep 5
          end
        end
      end
    end
  end
  
  def self.scrapingShop(shop_html)
    shop_url       = @url
    shop_name      = ''
    address        = ''
    tel            = ''
    access         = ''
    business_hours = ''
    holiday        = ''
    lat            = ''
    lng            = ''
    sale_name      = ''
    sale_date      = ''
    uid            = @category + '_' + @area.gsub(/\.html/, '') + '_' + @counter.to_s

    # 店舗名の取得
    shop_name = shop_html.xpath('td[1]').inner_text.strip.gsub(/\n/, '').gsub(/[\s]+/, ' ')
    
    # 閉店していたら登録しない
    if /閉店/ =~ shop_name
      return
    end
    p shop_name
    
    # 住所の取得
    address = shop_html.xpath('td[2]').inner_text.gsub(/^[0-9\-]*/, '')
    p address
    
    # TEL＆営業時間の取得
    shop_html.xpath('td[3]/text()').each_with_index do |a, i|
      case i
        when 0
          tel = a.inner_text.strip
        when 1
          business_hours = a.inner_text.strip
        end
    end
    
    # 緯度経度の取得
    latlng = self::getLatLng(address)
    lat = latlng[0]
    lng = latlng[1]

    @csv << ["#{uid}", "#{@category}", "#{shop_name}", "#{address}", "#{tel}", "#{access}", "#{business_hours}", "#{holiday}", "#{lat}", "#{lng}", "#{shop_url}", "", "#{sale_name}", "#{sale_date}", "", "", ""]
  end

  def self.getLatLng(address)
    page = open(@geocode_url + URI.encode(address))
    html = Nokogiri::HTML(page.read, nil, "UTF-8")
    
    lat = html.search("//geometry/location/lat").inner_text
    lng = html.search("//geometry/location/lng").inner_text

    return [lat, lng]
  end
end