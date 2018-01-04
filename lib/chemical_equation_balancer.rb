
Dir.glob("#{__dir__}/chemical_equation_balancer/*.rb").each do |filename|
  require filename
end
