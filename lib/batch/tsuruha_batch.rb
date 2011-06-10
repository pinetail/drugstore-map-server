require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'nkf'
require 'rexml/document'
require 'fastercsv'
require 'uri'
include REXML

class TsuruhaBatch
  
  @uri  = "http://www.tsuruha.co.jp/shop/"
  @pref_url = "http://www.tsuruha.co.jp/shop/?cm=l&pn="
  @url_list = []
#  @last_pref_id = 1
  @last_pref_id = 39
  #$shop_list = ["shp5hok_toh.html", "shp4kant.html", "shp6hoku.html", "shp7tokai.html", "shp1osaka.html", "shp2hyogo.html", "shp3kyna.html", "shp8chg_skk.html", "shp9ky_ok.html"]
  @shop_list = ["shp2hyogo.html"]
  @category = "tsuruha"
  @file_name = "/tmp/" + @category + "_" + Time.now.strftime("%Y%m%d%H%M%S") + '.csv'

  def self.execute
    FasterCSV.open(@file_name, "w") do |csv|
      for i in 1..@last_pref_id
        page = open(@pref_url + i.to_s + "&pr=20")
        html = Nokogiri::HTML(page.read, nil, 'UTF-8')

        list = html.search('//div[@id="main_contents"]//div[@class="itembox dot_linex"]//a')
        list.each_with_index do |a, i|
          href = a.xpath("@href").to_s

          if href != '' && @url_list.index(href).nil? then
            puts href
            @url_list.push(href)
            self::scrapingShop(href, csv)
            sleep 5
          end
        end
      end
    end
  end
  
  def self.scrapingShop(shop_html, csv)
    p @uri + shop_html.gsub(/\.\//, '')
    shop_url = @uri + shop_html.gsub(/\.\//, '')
    page = open(@uri + shop_html.gsub(/\.\//, ''))
    html = Nokogiri::HTML(page.read, nil, "UTF-8")
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
    uid = 'tsuruha_' + shop_html.scan(/id=([0-9]+)/)[0][0]

    # 店舗名の取得
    shop_name = NKF.nkf("-sW", html.search('//h3[@id="shopname"]').inner_text.gsub(/[　]*/, ''))
    
    # 店舗情報の取得
    list = html.search('//div[@id="main_contents"]//table[1]//tr')
    list.each_with_index do |tr, i|
      label = tr.xpath('th').inner_text
      value = NKF.nkf("-sW", tr.xpath('td').inner_text.strip.gsub(/\n/, '<br />').gsub(/〒[0-9\-]*/, ''))
      case label
        when '住所'
          address        = value
        when '電話番号'
          tel            = value
        when 'アクセス'
          access         = value
        when "営業時間"
          business_hours = value
        when '定休日'
          holiday        = value
      end
    end
    
    # 緯度経度の取得
    map_html = html.search('//div[@id="map"]').inner_text
    lat = map_html.scan(/latitude[\s]*=[\s]*([0-9\.]+)/)[0][0]
    lng = map_html.scan(/longitude[\s]*=[\s]*([0-9\.]+)/)[0][0]
      
    csv << ["#{uid}", "#{@category}", "#{shop_name}", "#{address}", "#{tel}", "#{access}", "#{business_hours}", "#{holiday}", "#{lat}", "#{lng}", "#{shop_url}", "", "#{sale_name}", "#{sale_date}", "", "", ""]
  end
end