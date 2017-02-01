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
			if ((count%100) == 0) 
				puts count
			end	
			if guess = r
				numCorrect+=1
			else
				numWrong+=1
				howWrong+= (guess-r).abs	
			end	
		end	
		puts "Number of guesses correct = #{numCorrect}"
		puts "Number wrong = #{numWrong}"
		puts "Percentage correct#{numCorrect/count}"
		puts "Average incorrectness of wrong guesses = #{howWrong/numWrong}"
	end	
end	