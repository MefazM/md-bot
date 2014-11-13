module UnitsProductionTask

  BUILDINGS = [:mage_barrack, :barrack, :gold_mine, :gold_storage, :bow_barrack, :stables]

  def unit_to_construct
    prod_buildings = @game_data[:buildings_production]
    building_data = @buildings.select{|uid, building| prod_buildings.key?(uid) && building[:ready] }.values.sample

    if building_data

      return prod_buildings[building_data[:uid].to_sym].select{|u| u[:level] <= building_data[:level]}.sample

    end




    nil

    rescue Exception => e

      binding.pry
  end

  def construct_unit
    unit = unit_to_construct

    unless unit.nil?

      request_constuct_unit(unit[:uid])

      $stdout.print('.')
    end
  end
end