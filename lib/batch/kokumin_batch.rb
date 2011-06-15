require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'nkf'
require 'rexml/document'
require 'fastercsv'
require 'uri'
include REXML

class KokuminBatch
  
  @uri  = "http://www.kokumin.co.jp/store/"
  @url_list = []
  @shop_list = ["hokkaido_chuo", "hokkaido_kita", "fukushima", "ibaragi", "saitama", "chiba", "tokyo_adachi", "tokyo_ota", "tokyo_shinagawa", "tokyo_kita", "tokyo_shinjuku", "tokyo_daito", "tokyo_chuo", "tokyo_nerima", "tokyo_nishitokyo", "kanagawa", "aichi", "kyoto", "osaka_abeno", "osaka_kita1", "osaka_suminoe", "osaka_chuo1", "osaka_tennoji", "osaka_namihaya", "osaka_izumi", "osaka_kisiwada", "osaka_matubara", "osaka_sakai1", "osaka_sayama", "osaka_tondabayasi", "osaka_takatsuki", "osaka_higashiosaka", "osaka_hirakata", "osaka_neyagawa", "hyogo_suma", "hyogo_nada", "hyogo_hyogo", "hyogo_ammagasaki", "hyogo_kakogawa", "nara", "wakayama", "tottori", "shimane", "fukuoka_kitakyushu", "fukuoka_fukuoka", "saga", "nagasaki", "kagoshima"]
  #@shop_list = ["ibaragi"]
  @category = "kokumin"
  @shop_url = ''
  @shop
  @file_name = "/tmp/" + @category + "_" + Time.now.strftime("%Y%m%d%H%M%S") + '.csv'
  @csv = ''

  def self.execute
    FasterCSV.open(@file_name, "w") do |@csv|
      @shop_list.each do |@shop|
      p @uri + @shop + ".html"
        @shop_url = @uri + @shop + ".html"
        page = open(@shop_url)
        html = Nokogiri::HTML(NKF.nkf('-wS', page.read), nil, "UTF-8")
    
        list = html.search('//div[@class="pkg storeDetail"]')
        list.each_with_index do |a, i|
          self::scrapingShop(a)
        end
        sleep 5
      end
    end
  end
  
  def self.scrapingShop(html)
    address        = ''
    tel            = ''
    business_hours = ''
    store_id       = html.xpath('h2/@id').to_s
    shop_url       = @shop_url + "#" + store_id
    uid            = @shop + '_' + store_id
    lat            = ''
    lng            = ''
  
    # 店舗名の取得
    shop_name = html.xpath('h2').inner_text.strip.gsub(/\n/, '<br />')
  
    # 店舗情報の取得
    list = html.xpath('table//tr')
    list.each_with_index do |tr, i|
      case i
      when 0
        address = tr.xpath('td[2]').inner_text.gsub(/〒[0-9\-]*/, '').strip.gsub(/\n/, '<br />').strip.gsub(/\t/, '')
      when 1
        tel = tr.xpath('td[2]').inner_text.strip.gsub(/\n/, '<br />')
      when 2
        business_hours = tr.xpath('td[2]').inner_text.strip.gsub(/\n/, '<br />')
      end
    end
  
    p address
    
    src = html.xpath('iframe/@src')
    map_url = @uri + src.to_s
  
  p map_url
    page = open(map_url)
    map_html = Nokogiri::HTML(page.read, nil, 'UTF-8')
    latlng = map_html.inner_text.scan(/GPoint\(([0-9\.]+),[\s]*([0-9\.]+)\)/)
  p latlng
    lat = latlng[0][1]
    lng = latlng[0][0]
  
    @csv << ["#{uid}", "#{@category}", "#{shop_name}", "#{address}", "#{tel}", "", "#{business_hours}", "", "#{lat}", "#{lng}", "#{shop_url}", "", "", "", "", "", ""]

  end
end