# class Animal
# 	def speak
# 		puts "hello!"
# 	end
# end

# class GoodDog < Animal
# 	attr_accessor :name

# 	def initialize(n)
# 		self.name = n
# 	end

# 	def speak
# 		super
# 		puts "hello again!"
# 	end
# end

# class Cat < Animal
# end

# sparky = GoodDog.new('sparky')
# oolong = Cat.new
# oolong.speak
# sparky.speak

# module Mammal
# 	class Dog
# 		def speak(sound)
# 			p "#{sound}"
# 		end
# 	end

# 	class Cat
# 		def say_name(name)
# 			p "#{name}"
# 		end
# 	end
# end

# buddy = Mammal::Dog.new
# kitty = Mammal::Cat.new

# class Animal
# 	def pub
# 		'public part' + self.protect
# 	end

# 	protected

# 	def protect
# 		'protected part'
# 	end
# end

# a_animal = Animal.new
# puts a_animal.pub
# puts a_animal.protect

class Student
	attr_accessor :name
	attr_writer :grade

	def initialize(grade)
		self.grade = grade
	end

	def better_grade_than?(student)
		return true if grade > student.grade
		false
	end

	protected

	attr_reader :grade
end

joe = Student.new(89)
bob = Student.new(90)
puts "Well done!" if joe.better_grade_than?(bob)
puts joe.grade



