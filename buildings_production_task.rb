module BuildingsProductionTask

  BUILDINGS = [:mage_barrack, :barrack, :gold_mine, :gold_storage, :bow_barrack, :stables]

  def building_to_construct
    uid = BUILDINGS.sample
    return uid if @buildings[uid].nil?

    begin
      

    if @buildings[uid][:ready] && @buildings[uid][:level] <= 5
      gd_uid = [uid.to_s, @buildings[uid][:level] || 1].join('_').to_sym

      if @coins[:coins_storage][:amount] > @game_data[:buildings_data][gd_uid][:price]
        return uid
      elsif rand(0..100) > 60
        return uid
      end
    end

    rescue Exception => e
      binding.pry
    end


    nil
  end

  def construct_building
    uid = building_to_construct

    unless uid.nil?
      # info "Try to construct building #{uid}..."
      write_data([Send::CONSTUCT_BUILDING, uid])
    end
  end
end