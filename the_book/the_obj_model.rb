module Speak
  def speak(sound)
    puts sound
  end
end


class GoodDog
  include Speak
end

spark = GoodDog.new
spark.speak("OOO")

=begin
How do we create an object in Ruby? Give an example of the creation of an object.
We create an object by defining a class and instantiating it by using the `new` method to create an instance, also known as an object.

What is a module? What is its purpose? How do we use them with our classes?
Create a module for the class you created in exercise 1 and include it properly.
A module is a collection of behaviors that is usable in other classes via mixins.
It allows us to group reusable code into one place.
We use them by calling the `include` method followed by the module name within the definition of the class.
=end
module TestModule
end

class ExampleClass
  include TestModule
end