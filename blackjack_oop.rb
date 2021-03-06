require 'pry'

class Card
	attr_accessor :suit, :value

	def initialize(s,v)
		@suit = s
		@value = v
	end

	def get_point
		point = 0
		case @value
		when 'J','Q','K'
			point = 10
		when 'A'
			point = 1;			
		else
			point = value.to_i
		end
		point
	end

	def to_s
		"#{suit}_#{value}"
	end
end

class CardsManager
	# @cards = {['spade','A'],['heart','A'],['diamond','A'],['club','A'],}

	def initialize(d)
		@cards = []
		suits = ['spade','heart','diamond','club']
		values = ['A','1','2','3','4','5','6','7','8','9','10','J','Q','K']
		# cards = suits.product(values)
		suits.each do |s|
			values.each do |v|
				@cards << Card.new(s,v)
			end
		end
		@cards * d
		@cards.shuffle!
	end

	def take_card
		@cards.pop
	end
end

class CardArray

	attr_accessor :cards

	def initialize
		@cards = []
		@countA = 0
	end

	def push(card)
		@cards << card
		@countA += 1 if card.value == 'A'
	end

	def get
		@cards
	end

	def count
		sum = 0
		@cards.each do |c|
			sum += c.get_point
		end 

		count = self.includeA?
		while sum <= 11 && count > 0
			sum += 10
			count -= 1
		end

		sum
	end

	def total_to_s
		"(" + self.count.to_s + " points.)"
	end

	def includeA?
		@countA
	end

	def to_s
		@cards.join(",")
	end
end

module Hand

	def add_card(card)
		@cardarray.push(card)
		message = "get card: " + card.to_s
		if @cardarray.count == 21
			@status = "win"
			message += " => BlackJack!"
			# binding.pry
		elsif @cardarray.count > 21
			@status = "lose"
			message += " => Busted!"
			# binding.pry
		else
			message
			# binding.pry
		end 
	end
	
	def get_all_cards
		@cardarray.get
	end

	def clear_all_cards
		@cardarray = CardArray.new
		@status = "none"
	end
end

class Dealer

	include Hand

	attr_accessor :cardarray, :status

	def initialize
		@cardarray = CardArray.new
		@status = "none"
	end

	# def add_card(card)
	# 	@cardarray.push(card)
	# 	message = "get card: " + card.to_s
	# 	if @cardarray.count == 21
	# 		@status = "win"
	# 		message += " => BlackJack!"
	# 		# binding.pry
	# 	elsif @cardarray.count > 21
	# 		@status = "lose"
	# 		message += " => Busted!"
	# 		# binding.pry
	# 	else
	# 		message
	# 		# binding.pry
	# 	end 
	# end
	
	# def get_all_cards
	# 	@cardarray.get
	# end

	def to_s
		"Dealer now has " + @cardarray.count.to_s + " points."
	end

	def status_to_s
		"Dealer #{status}"
	end

	def show_cards
		"Dealer => " + @cardarray.to_s
	end
end

class Player
	
	include Hand

	attr_accessor :cardarray, :status, :name

	def initialize(n)
		@cardarray = CardArray.new
		@status = "none"
		@name = n
	end	

	def to_s
		"Player #{name} now has " + @cardarray.count.to_s + " points."
	end

	def status_to_s
		"Player #{name} #{status}!"
	end

	def show_cards
		"Player #{name} => " + @cardarray.to_s
	end
end


class Deck
	attr_accessor :dealer, :status

	@@number = 0

	def initialize
		# @round = n
		@status = "none"
		@@number += 1
		@players = []
		@dealer = Dealer.new
		@cardmanager = CardsManager.new(1)
		# @winner = @dealer
		@high_point = 0
	end

	def clear
		@status = "none"
		@cardmanager = CardsManager.new(1)
		@high_point = 0
		@dealer.clear_all_cards
		@players.each {|p| p.clear_all_cards}
	end

	def add_player(name)
		player = Player.new(name)
		# player.name = name
		# binding.pry
		@players.push(player)
	end

	def get_first_two_cards
		#先發第一張
		@players.each do |p|
			p.add_card(@cardmanager.take_card)
		end
		@dealer.add_card(@cardmanager.take_card)
		#再發第二張
		@players.each do |p|
			p.add_card(@cardmanager.take_card)
		end
		@dealer.add_card(@cardmanager.take_card)
		#誰有什麼牌？
		@players.each {|p| puts p.show_cards}
		puts @dealer.show_cards
	end

	def get_players
		@players
	end

	def round?
		@@number.to_s
	end

	def start

		@players.each do |p|

			puts "===> " + p.name + "'s turn <==="
			puts p.to_s

			while true
				if p.status == "win"
					puts p.status_to_s
					@status = "end"
					return
				end

				puts "What's your move? 1)hit 2)pass"
				move = gets.chomp
				# puts
				if move == "1"
					puts p.add_card(@cardmanager.take_card) + " " + p.cardarray.total_to_s 
					case p.status
					when "win"
						puts p.status_to_s
						@status = "end"
						return
					when "lose"
						puts p.status_to_s
						break
					else
						next
					end
				elsif move == "2"
					puts "Player " + p.name + " pass! " + p.cardarray.total_to_s
					puts
					if p.cardarray.count > @high_point
						@high_point = p.cardarray.count 
						@winner = p
					end
					break
				else
					puts "Please enter 1 or 2 !"
				end	
				# puts ""		
			end
		end		
	end

	def dealer_turn
		if @status != "end"
			puts
			puts "Dealer's turn!"
			puts @dealer.to_s

			while @dealer.cardarray.count <= 17

				puts @dealer.add_card(@cardmanager.take_card)
				case @dealer.status
				when "win"
					puts @dealer.status_to_s						
					return
				when "lose"
					puts @dealer.status_to_s					
					break
				end				
			end
			puts @dealer.to_s
			#compare everyone's cards, find the winner in players
			self.who_win?

		end
	end

	def who_win?
		puts "===> Compare! <==="

		if @dealer.status != "lose" 
			if @dealer.cardarray.count > @high_point
				@dealer.status = "win"
				puts @dealer.status_to_s
			elsif @dealer.cardarray.count < @high_point
				@winner.status = "win"
				puts @winner.status_to_s
			else
				puts "no one win."
			end
		elsif @high_point > 0
			@winner.status = "win"
			puts @winner.status_to_s
		else
			puts "no one win."
		end
	end
end

#new
#player get in
#start

class BlackJack
	def initialize
		@deck = Deck.new
	end

	def set_players
		puts "Player's name?(till Enter)"
		while true
			name = gets.chomp
			if name == ""
				break
			else
				@deck.add_player(name)
			end
		end
	end

	def start
		while true	
			puts "Enter S to start a new game."
			input = gets.chomp.upcase
			if input == "S"
				# deck1 = Deck.new
				@deck.clear
				puts "=== Start Game " + @deck.round? + " ==="
				puts "Total " + @deck.get_players.count.to_s + " players, game start!"
				puts

				puts "=>everyone gets two cards."
				@deck.get_first_two_cards
				puts
				# puts deck1.round?
				@deck.start
				puts 

				@deck.dealer_turn
				# deck1.who_win?

			else
				puts "=== End ==="
				break
			end
		end
		
	end
end

blackjack = BlackJack.new
blackjack.set_players
blackjack.start


