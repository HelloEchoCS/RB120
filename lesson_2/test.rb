class Test
  def self.a_method
    42
  end
end

class Child < Test
  
end


p Test.a_method
p Child.a_method