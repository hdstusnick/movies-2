require "byebug"
require 'descriptive_statistics'


class MovieData
	def load_data(file)
		#load data into an array that stores the info, a hash that maps movies to their ratings, and a hash that maps users to the movie they saw and what rating they gave it. 
		# 0 = user, 1 = movie, 2 = rating 
		@data = []
		@moviePop = Hash.new # a map of the movies to an array of the ratings they recieved
		@movieSeen = Hash.new # a map of the users to the movies they have seen
		File.open(file).each do |d|
			d = d.split(" ")
			d = d.first(3)
			@data.push(d)
			if(@moviePop.key?(d[1]))
				@moviePop[d[1]].push(d[2])
			else
				@moviePop[d[1]]	= [d[2]]
			end	
			if(@movieSeen.key?(d[0]))
				@movieSeen[d[0]].push(d.last(2))
			else
				@movieSeen[d[0]] = [d.last(2)]
			end	
		end
	end	
	#create a number betwee 5.0 and 0.0 that is the average rating that a movie had and returns that number as a float
	def popularity(movie_id)
		lookUp = movie_id.to_s
		ratings = @moviePop[lookUp]
		sum = 0
		ratings.each do |r|
			r = r.to_i
			sum += r
		end	
		return (sum.to_f/(ratings.size)).round(3)
	end	
	#creates a hash of movies to their average ratings and sorts them from highest to lowest. This returns the hash so that the user can see the order of the movies as well as the movies rating 
	def popularity_list
		@rankings = Hash.new
		@data.each do |x|
			if(!@rankings.key?(x[1]))
				r = popularity(x[1])
				@rankings[x[1]] = r
			end	
		end	
		@rankings = Hash[@rankings.sort_by{|_k, v| v}.reverse]
		return @rankings
	end
	#expecting integers as input, this creates and returns an int represents how similar two users were in how they rated movies.
	def similarity(user1,user2)
		sim = 0
		user1 = user1.to_s
		user2 = user2.to_s
		u1 = @movieSeen[user1]
		u2 = @movieSeen[user2]
		# +6 similarity if they have seen the same movie, -1 for each rating step away from each other for the same movie
		if(u1.length >= u2.length)
			(0..u2.length-1).each do |i|
				if(u1[i][0].to_i == u2[i][0].to_i)
					x = 6-(u1[i][1].to_i-u2[i][1].to_i).abs
					sim += x
				end	
			end	
		else
			(0..u1.length-1).each do |i|
				if(u1[i][0].to_i == u2[i][0].to_i)
					x = 6-(u1[i][1].to_i-u2[i][1].to_i).abs
					sim += x
				end
			end	
		end	
		return sim
	end
	#expecting an int as input, this creates and returns a map of users that are similar to the given user to their similarity rating. The map is trimmed to only include non 0 ratings and is sorted from most to least similar. 
	def most_similar(u)
		similarToUser = Hash.new
		@movieSeen.keys.each do |x|
			if(!(u == x.to_i))
				if(similarity(u, x.to_i)>0)
					similarToUser[x] = similarity(u, x.to_i)
				end
			end	
		end	
		similarToUser = Hash[similarToUser.sort_by{|_k, v| v}.reverse]
		return similarToUser
	end	
	def predict(user, movie)
		simUsers = most_similar(user)
		users = simUsers.keys
		sameMovieUsers = Hash.new
		users.each do |u|
			movies = @movieSeen[u]
			movies.each do |m, r|
				if(m[0] == movie.to_s)
					#add to sameMovieUsers a key of the similarity and the rating that person gave the movie
					sameMovieUsers[simUsers[u.to_s]] = r
				end
			end	
		end	
		weightedTotal = 0
		totalWeights = 0
	
		sameMovieUsers.each do |weight, _r|
			totalWeights += (weight.to_i)
			weightedTotal += ((sameMovieUsers[weight].to_i)*(weight.to_i))
		end	
		if totalWeights == 0
			return 3
		else	
		averageRating = weightedTotal/totalWeights
		end
		return averageRating.round
	end	

	def getData
		return @data
	end	
end
class Validator
	def check(b, t)
		d = t.getData
		numCorrect = 0
		numWrong = 0
		howWrong = 0
		count = 0
		d.each do |u, m, r|
			guess = b.predict(u, m)
			count+= 1
			if ((count%1000) == 0) 
				puts count
			end	
			
			if (guess == r.to_i)
				numCorrect+=1
			else
				numWrong+=1
				howWrong+= (guess-(r.to_i)).abs	
			end	
		end	
		
		# puts numCorrect
		# puts numWrong
		# puts howWrong/numWrong
		puts "Number of guesses correct = #{numCorrect}"
		puts "Number wrong = #{numWrong}"
		averageCorrect = ((numCorrect.to_f)/count).round(2)
		puts "Percentage correct #{averageCorrect}"
		averageHowWrong = ((howWrong.to_f)/numWrong).round(2)
		puts "Average incorrectness of wrong guesses = #{averageHowWrong}"
	end	
end	


class Control

	def run
		b = MovieData.new
		b.load_data('u1.base')
		t = MovieData.new
		t.load_data('u1.test')
		v = Validator.new
		v.check(b, t)
	end	

end	

c = Control.new
c.run

