# class GoodDog
# 	attr_accessor :name, :height, :weight

# 	def initialize(n, h ,w)
# 		@name = n
# 		@height = h
# 		@weight = w
# 	end

# 	def speak
# 		"#{name} says Arf!" # calling the `name` method here
# 	end

# 	def change_info(n, h, w)
# 		self.name = n
# 		self.height = h
# 		self.weight = w
# 	end

# 	def info
# 		"#{name} weighs #{weight} and is #{height} tall."
# 	end
# end

# sparky = GoodDog.new("Sparky", '12 inches', '10 lbs')
# puts sparky.info

# sparky.change_info('Spartacus', '24 inches', '45 lbs')
# puts sparky.info

module Transmission
	def is_awd?
		true
	end
end

class Vehicle
	attr_accessor :color, :year, :model

	@@count = 0

	def initialize(color, year, model)
		self.color = color
		self.year = year
		self.model = model
		@@count += 1
	end
	

	def show_age
		puts "the age of this car is #{age}"
	end

	def self.mileage(gas, distance)
		puts gas.to_f / distance
	end

	def self.show_count
		puts @@count
	end

	private

	def age
		Time.now.year - year.to_i
	end

end

class MyCar < Vehicle
	include Transmission
	TYPE = "wagon"
end

class MyTruck < Vehicle
	TYPE = "truck"
end

subaru = MyCar.new("silver", "2007", "subaru legacy")
subaru.show_age