require 'fastercsv'
require 'zipruby'

class ApiController < ApplicationController
  def get
    @shops = Shop.all

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @shops }
    end
  end
  
  def export
    
    # データベースからの検索処理
    @shops = Shop.all
    
    # 出力ファイルのコンテンツタイプの決定
    cntnt_type = ""
    if request.user_agent =~ /windows/i then
      # クライアント環境がWindowsの場合はExcel形式で返す
      cntnt_type = "application/vnd.ms-excel"
    else
      # それ以外の場合にはCSV形式で返す
      cntnt_type = "text/csv"
    end
    
    # ファイル名称の設定
    file_name = Time.now.strftime("%Y%m%d%H%M%S")
    tmp_zip = "#{RAILS_ROOT}/public/system/files/#{file_name}.zip"
    
    # CSVオブジェクトを生成し、データをセットしていく
#    FasterCSV.open(file_name, "w") do |csv|
    csv_text = FasterCSV.generate(:force_quotes => true) do |csv|
#    CSV::Writer.generate(output = "") do |csv|
      for shop in @shops
        csv << [shop.uid, shop.category, shop.name, shop.address, shop.tel, shop.access, shop.business_hours, 
        shop.holiday, shop.lat, shop.lng, shop.pc_url, shop.mobile_url, shop.column01, shop.column02, shop.column03, 
        shop.column04, shop.column05, shop.use_flg, shop.created_at, shop.updated_at]
      end
    end
    
    Zip::Archive.open(tmp_zip, Zip::CREATE) do |ar|
      ar.add_buffer("#{file_name}.csv", NKF.nkf('-U -s -Lw', csv_text))
    end

    # CSVファイルの出力
#    send_data(NKF.nkf('-U -s -Lw', output), :type => cntnt_type, :filename => file_name)
  end
  
  def latest_version
    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => "20110609" }
    end
  end
end
