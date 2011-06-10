require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'nkf'
require 'rexml/document'
require 'fastercsv'
require 'uri'
include REXML

class KirindoBatch
  
  @uri  = "http://www.tsuruha.co.jp/shop/"
  @pref_url = "http://www.kirindo.co.jp/shop/"
  @url_list = []
  @shop_list = ["shiga", "kyoto", "osaka", "hyogo", "nara", "wakayama", "mie", "tokushima", "kagawa", "ishikawa", "saitama", "chiba", "tokyo", "kanagawa"]
  #@shop_list = ["kanagawa"]
  @category = "kirindo"
  @file_name = "/tmp/" + @category + "_" + Time.now.strftime("%Y%m%d%H%M%S") + '.csv'
  @csv = ''

  def self.execute
    FasterCSV.open(@file_name, "w") do |@csv|
      @shop_list.each do |shop|
        page = open(@pref_url + shop +"/")
        html = Nokogiri::HTML(page.read, nil, 'UTF-8')

        list = html.search('//table[@class="shop2"][1]//a')
        list.each_with_index do |a, i|
          href = a.xpath("@href").to_s

          if href != '' && @url_list.index(href).nil? && /www\.kirindo\.co\.jp/ =~ href then
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
    p shop_html
    page = open(shop_html)
    html = Nokogiri::HTML(NKF.nkf('-wE', page.read), nil, "UTF-8")
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
    uid = @category + '_' + shop_html.scan(/([a-zA-Z0-9\-]+)\.html/)[0][0].to_s
    # 店舗名の取得
    shop_name = NKF.nkf("-sW", html.search('//h2[@class="shop_midashi"]').inner_text.gsub(/[　]*/, ''))
    
    # 店舗情報の取得
    list = html.search('//div[@class="document"]//dd')
    list.each_with_index do |tr, i|
      value = NKF.nkf("-sW", tr.inner_text.strip.gsub(/\t/, '').gsub(/\n/, '<br />').gsub(/〒[0-9\-]*[　]*/, ''))
      case i
        when 0
          address        = value
        when 1
          tel            = value
        when 2
          business_hours = value
        when 3
          holiday        = value
        when 4
      end
    end
    
    # 緯度経度の取得
    head_html = html.search('//head').inner_text
    latlng = head_html.scan(/GLatLng\(([0-9\.]+),[\s]*([0-9\.]+)\)/)
    lat = latlng[0][0]
    lng = latlng[0][1]
    
    @csv << ["#{uid}", "#{@category}", "#{shop_name}", "#{address}", "#{tel}", "#{access}", "#{business_hours}", "#{holiday}", "#{lat}", "#{lng}", "#{shop_html}", "", "#{sale_name}", "#{sale_date}", "", "", ""]
  end
end