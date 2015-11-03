require './factory'

Album = Factory.new(:title, :band, :year) do
	def introduce
		"#{band} - \"#{title}\" (#{year})"
	end
end

kill = Album.new("Kill", "Cannibal Corpse", 2006)
la_woman = Album.new("L.A. Woman", "The Doors", 1971)

kill.title = "Torture"
kill.year = 2012

puts kill.introduce
puts la_woman.introduce
puts kill == la_woman 

Factory.new("Person", :name, :age) do
	def about
		"My name is #{name} and I'm #{age}"
	end
end

vincent = Person.new("Vincent", 44)
puts vincent.about 