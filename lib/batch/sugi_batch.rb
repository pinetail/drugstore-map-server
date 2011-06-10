require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'nkf'
require 'rexml/document'
require 'fastercsv'
require 'uri'
include REXML

class SugiBatch
  
  @uri  = "http://www.drug-sugi.co.jp/shopsearch/"
  @pref_url = "http://www.drug-sugi.co.jp/shopsearch/pref_shop.php?pref_id="
  @url_list = []
  @first_pref_id = 1
  @last_pref_id = 16
#  @last_pref_id = 8
  #$shop_list = ["shp5hok_toh.html", "shp4kant.html", "shp6hoku.html", "shp7tokai.html", "shp1osaka.html", "shp2hyogo.html", "shp3kyna.html", "shp8chg_skk.html", "shp9ky_ok.html"]
  @shop_list = ["shp2hyogo.html"]
  @category = "sugi"
  @file_name = "/tmp/" + @category + "_" + Time.now.strftime("%Y%m%d%H%M%S") + '.csv'

  def self.execute
    FasterCSV.open(@file_name, "w") do |csv|
      for i in @first_pref_id..@last_pref_id
        page = open(@pref_url + i.to_s)
        html = Nokogiri::HTML(page.read, nil, 'UTF-8')

        list = html.search('//table[@id="tbl-station"]//a')
        list.each_with_index do |a, i|
          href = a.xpath("@href").to_s

          if href != '' && @url_list.index(href).nil? then
            puts href
            @url_list.push(href)
            SugiBatch::scrapingShop(href, csv)
            sleep 5
          end
        end
      end
    end
  end
  
  def self.scrapingShop(shop_html, csv)
    p @uri + shop_html
    shop_url = @uri + shop_html
    page = open(@uri + shop_html)
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

    # 店舗名の取得
    shop_name = NKF.nkf("-sW", html.search('//p[@id="shop_namae"]/text()').inner_text.gsub(/[　]*/, ''))
    
    # 住所の取得
    address = NKF.nkf("-sW", html.search('//table[@id="shop_name"]/tr[2]/td').inner_text.gsub(/\t/, '').gsub(/〒\n[0-9\-]*\n/, '').gsub(/\n/, '<br />'))
    
    # 店舗情報の取得
    list = html.search('//table[@id="shopinfo"]//tr')
    list.each_with_index do |tr, i|
      case i
        when 0
          business_hours = NKF.nkf("-sW", tr.xpath('td[2]').inner_text.strip.gsub(/\t/, '').gsub(/\n/, ''))
          holiday        = NKF.nkf("-sW", tr.xpath('td[6]').inner_text.strip.gsub(/\t/, ''))
        when 1
          tel            = NKF.nkf("-sW", tr.xpath('td[2]').inner_text.strip.gsub(/\t/, ''))
      end
    end
    
    # 緯度経度の取得
    latlng = shop_html.scan(/pt=([0-9\.]+),([0-9\.]+)/)
    lat = latlng[0][1]
    lng = latlng[0][0]
    
    # 店舗IDの取得
    sid = shop_html.scan(/id=([0-9\.]+)/)
    uid = "sugi_" + sid[0][0].to_s

    csv << ["#{uid}", "#{@category}", "#{shop_name}", "#{address}", "#{tel}", "#{access}", "#{business_hours}", "#{holiday}", "#{lat}", "#{lng}", "#{shop_url}", "", "#{sale_name}", "#{sale_date}", "", "", ""]
  end
end