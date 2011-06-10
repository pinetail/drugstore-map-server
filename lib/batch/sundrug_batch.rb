require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'nkf'
require 'rexml/document'
require 'fastercsv'
require 'uri'
include REXML

class SundrugBatch
  
  @uri  = "http://www.sundrug.co.jp/store/"
  @pref_url = "http://www.sundrug.co.jp/store/list_area.php?gid=1&keyword="
  @list_url = "http://www.sundrug.co.jp/store/list_area.php"
  @url_list = []
  @last_pref_id = 1
  @shop_list = ["北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県", "新潟県", "長野県", "富山県", "石川県", "福井県", "東京都", "神奈川県", "埼玉県", "千葉県", "茨城県", "栃木県", "群馬県", "山梨県", "愛知県", "岐阜県", "静岡県", "三重県", "大阪府", "兵庫県", "京都府", "滋賀県", "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]
  #@shop_list = ["兵庫県"]
  @category = "sundrug"
  @file_name = "/tmp/" + @category + "_" + Time.now.strftime("%Y%m%d%H%M%S") + '.csv'
  @csv = ""

  def self.execute
    FasterCSV.open(@file_name, "w") do |@csv|
      @shop_list.each do |shop|

        page = open(@pref_url + URI.encode(shop))
        html = Nokogiri::HTML(page.read, nil, 'UTF-8')

        self::access(html)
        
        extra = html.search('//div[@class="extraBox"]/div[@id="page"]//a')
        if extra.size > 0 then
          extra.each do |a|
            href = a.xpath("@href").to_s

            if href != '' && @url_list.index(href).nil? then
              puts href
              @url_list.push(href)
              page = open(@list_url + URI.encode(href))
              html = Nokogiri::HTML(page.read, nil, 'UTF-8')
              self::access(html)
            end

          end
        end
      end
    end
  end
  
  def self.access(html)

    list = html.search('//table[@class="storeListTable"]//a')
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
  
  def self.scrapingShop(shop_html)
    p @uri + URI.encode(shop_html)
    shop_url = @uri + URI.encode(shop_html)
    page = open(shop_url)
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
    shop_name = NKF.nkf("-sW", html.search('//div[@id="textArea"]/h1').inner_text.gsub(/[　]*/, ''))
    
    # 店舗情報の取得
    list = html.search('//div[@id="textArea"]/dl/dd')
    list.each_with_index do |tr, i|
      value = NKF.nkf("-sW", tr.inner_text.strip.gsub(/\t/, '').gsub(/\n/, '<br />'))
      case i
        when 0
          address        = value
        when 1
        when 2
          tel            = value
        when 3
        when 4
          business_hours = value
      end
    end
    
    # 緯度経度の取得
    head_html = html.search('//head').inner_text
    lat = head_html.scan(/def_lat[\s]*=[\s]*([0-9\.]+)/)[0][0]
    lng = head_html.scan(/def_long[\s]*=[\s]*([0-9\.]+)/)[0][0]
    
    # 店舗IDの取得
    sid = shop_html.scan(/id=([0-9\.]+)/)
    uid = @category + "_" + sid[0][0].to_s

p ["#{uid}", "#{@category}", "#{shop_name}", "#{address}", "#{tel}", "#{access}", "#{business_hours}", "#{holiday}", "#{lat}", "#{lng}", "#{shop_url}", "", "#{sale_name}", "#{sale_date}", "", "", ""]
    @csv << ["#{uid}", "#{@category}", "#{shop_name}", "#{address}", "#{tel}", "#{access}", "#{business_hours}", "#{holiday}", "#{lat}", "#{lng}", "#{shop_url}", "", "#{sale_name}", "#{sale_date}", "", "", ""]
  end
end