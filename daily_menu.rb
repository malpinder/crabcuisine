# all available ingredients
# @ingredients = YAML.load_file("ingredients")


# past seven days @menus
#history = YAML.load_file("history")

def random_ingredient(tag)
  pool = []
  @ingredients.select { |i, tags| tags.include?(tag) }.each_pair do |ingredient, tags|
    next if @history.first.include?(ingredient)
    next if @menu.include?(ingredient)
    chance = 8
    @history.each_with_index { |daily_menu, days_ago| chance =- (8 - days_ago) if daily_menu.include?(ingredient) }
    chance =+ 1 if tags.include?(:liked)
    chance =- 1 if tags.include?(:disliked)
    chance.times { pool << ingredient }
  end
  raise pool.inspect if pool.any? {|p| p.nil?}
  pool.sample
end

def had_yesterday?(tag)
  @history[0].any? { |ingredient| @ingredients[ingredient].include?(tag) }
end

def had_this_week?(tag)
  @history.first(7).flatten.any? { |ingredient| @ingredients[ingredient].include?(tag) }
end

def present_in_menu?(tag)
  @menu.any? { |ingredient| @ingredients[ingredient].include?(tag) }
end

def generate_daily_menu
  @menu = []
  # proteins, two portions
  2.times do 
    if rand(7) == 0
      @menu << random_ingredient(:plant_protein)
    else
      @menu << random_ingredient(:animal_protein)
    end
  end

  # fruit and/or veg
  r = rand(3)
  if r == 0
    @menu << random_ingredient(:fruit)
    @menu << random_ingredient(:veg)
  elsif r == 1
    @menu << random_ingredient(:fruit)
  else
    @menu << random_ingredient(:veg)
  end

  # carbs
  unless present_in_menu?(:carbs) || had_yesterday?(:carbs)
    @menu << random_ingredient(:carbs)
  end

  unless present_in_menu?(:fat) || had_yesterday?(:fat)
    @menu << random_ingredient(:fat)
  end
  

  # bright colours
  unless present_in_menu?(:carotenoids) || had_yesterday?(:carotenoids)
    @menu << random_ingredient(:carotenoids)
  end

  # micronutrients and treats
  [:astaxanthin, :calcium, :cellulose, :tannin, :treat, :zeaxanthin].each do |tag|
    unless present_in_menu?(tag) || had_this_week?(tag)
      @menu << random_ingredient(tag)
    end
  end
  puts @menu.inspect
  

  until @menu.length >= 6
    lucky_ingredient = @ingredients.keys.sample
    raise if lucky_ingredient.nil?
    unless @menu.include?(lucky_ingredient) || @history.first(7).flatten.include?(lucky_ingredient)
      @menu << lucky_ingredient
    end
  end


  @menu.each { |ingredient| print "#{ingredient}, " }; puts
  # store_menu ?
  @history.unshift(@menu)
end
