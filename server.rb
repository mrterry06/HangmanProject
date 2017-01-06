
require 'sinatra'
#require 'sinatra/reloader'



#ClASSES

class Responses
	#Class to give sarcastic responses
	def initialize; end

	def self.wrong
		inputs = ["You missed, Peter Griffin would be ashamed",
			"I'm sorry to tell you this, but that was not an included character",
			"My senses tell me that was not a correct character",
			"I encourage you to choose a correct letter next time",
			"You got it next time champ. I believe in you!",
			"Heres a hint: Look into the future, I believe you can get the correct answer next time"
		]
		inputs[rand(inputs.length)]
	end

	def self.right
		inputs = ["Correcto Champo",
			"You should go to Vegas! That was Correct",
			"Oh My, You got it!",
			"You're the Steph Curry of Hangman! That was correct",
			"I'm beginning to think you can see into the future, that was correct",
			"You're on the verge of being a champion"
		]
		inputs[rand(inputs.length)]
	end

end


#METHODS

def hint_generator(word)
  target_word_letters = word.split("")

  while target_word_letters.length < (word.length + 4)
  	#generates a random letter between a - z
  	newLetter = (rand( ("a".ord)..("z".ord) )).chr
  	#adds that letter to target_word_letters if the letter isn't already included
  	target_word_letters.insert(rand(target_word_letters.length), newLetter) if !target_word_letters.include?(newLetter)

  end
  settings.hint = target_word_letters
end


def redirect_check(doMatchCheck = false)
	#doMatchCheck, if true, will check to see if our target_word and guess word match, will redirect if so
	#This is to handle if user gets words with remaining lives
	redirect to("/") if $lives <= 0 || ( ( settings.target_word == $guess_status.gsub(" ", "") ) && doMatchCheck ) 
end


def set_difficulty(diff)
	
	@@allWords = Array.new
	
	@@allWords = File.open('files/dictionary.txt', "r").readlines if @@allWords.empty?
	# checks to see if difficulty parameter is set, if set, chooses a random word upto the length of diff argument
	if !diff.nil?
		words = @@allWords.select do |line|
			line.length == diff.to_i + 1
		end
		#chomp here instead of within readlines method to prevent uneeded operations
		words.map! { |val| val.chomp }
		settings.target_word = words[rand(words.length)]
		$footer_res = "Good Luck"
		hint_generator(settings.target_word)
	end 

end


def word_check(guess)
	if guess.nil?
		@@guesses, guess_status = Array.new, Array.new 
		$lives = 5
		(settings.target_word.length).times { guess_status << "__" }
		$guess_status = guess_status.join(" ")
		
		settings.response = "Enter in a letter to get started. You only have 5 lives. Use them wisely if you can :). 
		This text will change to give you sarcastic responses as you embark on your journey. The footer will give you 
		feedback on if your input was correct! Enjoy!"
		return
	end
	guess.downcase!


	if $guess_status.include?(guess) || @@guesses.include?(guess)

		 guess != '' ? ( $footer_res, settings.response = "You already tried that", "You already tried that :P")
		 			 : ( $footer_res, settings.response = "Enter a value", "It is wise to enter a value" ) 
		redirect_check(true) 
		return
	end


	if settings.target_word.include?(guess)
		guess_status_arr = $guess_status.split(" ").map.with_index do |val, i|
			val = guess  unless settings.target_word[i] != guess
			val
		end
		@@guesses << guess
		$guess_status, $footer_res, settings.response = guess_status_arr.join(" "), "Right", Responses.right
	else
		redirect_check(true)
		settings.response, $footer_res	 = Responses.wrong, "Wrong"
		$lives -= 1
		@@guesses << guess
	end
	

end



#ROUTES


get '/' do
	# Checks to see if difficulty parameter is set, if set, redirects to '/play' for user to play 
	set_difficulty(params['difficulty'])
	redirect to('/play') if !params['difficulty'].nil?
	erb :index
end

get '/play' do
	
	redirect to('/') if settings.target_word.nil?

	word_check(params['guess'])
	erb :play, 
		:locals => {  
			:guess_status => $guess_status,  
			:lives => $lives.to_i, 
			:footer_res => $footer_res
		}
end





