require 'rubygems'
require 'gosu'
module ZOrder
	MENU, INFO, CHAR, LEADERBOARD, BACKGROUND, MIDDLE, TOP, POPUP, BUTTON= *0..8
end

class Food
	#attr_reader :ranX, :ranY
		
	def initialize(window)
		@window = window
		@ranX = rand (0...634)
		@ranY = rand (0...474)
	end
	
	def ranX
		@ranX
	end
	
	def ranY
		@ranY
	end
	
	def spawn_food
		Gosu.draw_rect(@ranX, @ranY, 6, 6, Gosu::Color::FUCHSIA, ZOrder::MIDDLE, mode=:default)
	end		
end

class Sfood

	def initialize(window)
		@window = window
		@Super_ranX = rand (0...615)
		@Super_ranY = rand (0...445)
		@vel_x = rand (1..2)
		@vel_y = rand (1..2)
	end
	
	def super_ranX
		@Super_ranX
	end
	
	def super_ranY
		@Super_ranY
	end
	
	def spawn_super_food
		Gosu.draw_rect(@Super_ranX, @Super_ranY, 25, 25, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
	end	
end

class Colour

	def initialize(window)
		@window = window
		@Black = Gosu::Color.argb(0xff_000000)
		@Gray = Gosu::Color.argb(0xff_808080)
		@White = Gosu::Color.argb(0xff_ffffff)
		@Turquoise = Gosu::Color.argb(0xff_40E0D0)
		@Red = Gosu::Color.argb(0xff_ff0000)
		@Green = Gosu::Color.argb(0xff_00ff00)
		@Blue = Gosu::Color.argb(0xff_0000ff)
		@Yellow = Gosu::Color.argb(0xff_ffff00)
		@Fuchsia = Gosu::Color.argb(0xff_ff00ff)
		@Cyan = Gosu::Color::CYAN
	end
	
	def black
		@Black
	end
	
	def gray
		@Gray
	end
	
	def white
		@White
	end
	
	def turquoise
		@Turquoise
	end
	
	def red
		@Red
	end
	
	def green
		@Green
	end
	
	def blue
		@Blue
	end
	
	def yellow
		@Yellow
	end
	
	def fuchsia
		@Fuchsia
	end
	
	def cyan
		@Cyan
	end
end

class Leaderboard
	attr_accessor = :score 
	
	def initialize (p_score)
		@score = p_score
	end
	
	#puts every single value from score.txt into an array
	def read_score(score_file)
		score_array = []
		for i in 0..score_file.length-1
			score_array << score_file[i]
		end
		return score_array
	end
	
	#obtain the score in game 
	def obtain_score_from_game
		@score 
		return @score
	end
	
	#append a new score obtained in game into the score.txt 
	def write_score
		score = obtain_score_from_game
		leaderboard = File.open("score.txt", "a")
		if leaderboard
			leaderboard.syswrite(score)
			leaderboard.syswrite("\n")
			leaderboard.close
		end
	end
	
	#extract the values from score.txt 
	def display_leaderboard_ingame
		leaderboard = File.read("score.txt").split
		array = read_score(leaderboard)    #puts every single value from score.txt into an array
		return array
	end
	
	#calls the write_score function
	def main
		write_score
	end
end			
			
			
	
class GameWindow < Gosu::Window

	def initialize
		super 640,480,false
		self.caption = "cells"
		@view = ZOrder::MENU
		@rot = 0
		@menu_font = Gosu::Font.new(40)
		@font = Gosu::Font.new(20)
		@back_button_img = Gosu::Image.new("media/back_button.png")
		@background_img = Gosu::Image.new("media/background.jpg")
		@info_background_img = Gosu::Image.new("media/info_bground.jpg")
		@main_background_img = Gosu::Image.new("media/woods.jpg")
		@color_background_img = Gosu::Image.new("media/color_bground.jpg")
		@selected_img = Gosu::Image.new("media/selected.png")
		@arrow_key_img = Gosu::Image.new("media/arrowkey.png")
		@shift_img = Gosu::Image.new("media/shift.png")
		@width = 640
		@height = 480
		@cordX = 280
		@cordY = 200
		@sizeX = 50.0
		@sizeY = 50.0
		@speed = 1
		@score = 500
		@SPAWN = Food.new(self)
		@SPAWN_SUPER = Sfood.new(self)
		@pick_color = Colour.new(self)
		@color = Gosu::Color.argb(0xff_00ffff)
		@RNG = rand(0...100)
		@value1 = false
		@value2 = false
		@selected_x = 380
		@selected_y = 150
		@pellet = Array.new
		@score_ranking = []
		@confirmation = false
	end
	
	def update	
		#press spacebar to start the game
		if @view == ZOrder::MENU && button_down?(Gosu::KbSpace)
			@view = ZOrder::BACKGROUND
		end
		
		#button to move left
		if button_down?(Gosu::KbLeft)
			if @cordX != 0 and @cordX >= 0
				@cordX -=@speed
			end
		end
		
		#button to move right
		if button_down?(Gosu::KbRight)
			if @cordX != (@width - @sizeX) and @cordX <= (@width - @sizeX)
				@cordX +=@speed
			end
		end
		
		#button to move up
		if button_down?(Gosu::KbUp)
			if @cordY != 0 and @cordY >= 0
				@cordY -=@speed
			end
		end
		
		#button to move down
		if button_down?(Gosu::KbDown)
			if @cordY != (@height - @sizeY) and @cordY <=(@height - @sizeY)
				@cordY +=@speed
			end
		end
		
		#increases speed but decreases size when left shift button is clicked
		if button_down?(Gosu::KbLeftShift)
			if @sizeX <=15
				@speed = 1
			else
				@speed = 1.6
				@sizeX -= 0.1
				@sizeY -= 0.1
				@score -=1
			end
		else
			@speed = 1
		end

		#if food is eaten, spawn new, increase character's size and increase total score
		collect_food(@pellet)
			
		#if super food is eaten, spawn new, increase character's size and score
		if super_food_eaten
			if @value2 == true
				@sizeX +=10
				@sizeY +=10
				@score +=100
				@value2 = false
				@SPAWN_SUPER = Sfood.new(self)
			end
		end	
		
		#spinning animation in main menu page 
		if @view == ZOrder::MENU
			@rot += 20
			sleep(0.2)
		end
		
		#spawn new food if the conditions are met
		if rand(100) < 5 and @pellet.size <= 20
			@pellet.push(generate_food)
		end
		
		#Display a THUMBS UP on the color selected by the player ( character color )
		selected_color
		
		#returns an array to score the rankings from highest to lowest
		leaderboard_ranking_list
		
	end
	
	
	def draw
		#if Z order is in MENU, draw items below
		if @view == ZOrder::MENU
			@main_background_img.draw(0, 0, ZOrder::BACKGROUND, 1.6, 1.6)
			draw_menu
			Gosu.rotate(@rot,327.5,250){Gosu.draw_rect(280, 200, 95, 100, @color, ZOrder::MIDDLE, mode=:default)}
			Gosu.draw_rect(280, 320, 95, 40, Gosu::Color::CYAN, ZOrder::MIDDLE, mode=:default)
			@font.draw_text("INFO", 305, 330, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK) 
			Gosu.draw_rect(280, 370, 95, 40, Gosu::Color::CYAN, ZOrder::MIDDLE, mode=:default)
			@font.draw_text("COLOR", 295, 380, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			Gosu.draw_rect(280, 420, 95, 40, Gosu::Color::CYAN, ZOrder::MIDDLE, mode=:default)
			@font.draw_text("SCORE", 295, 430, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK) 
		#if Z order is in INFO, draw items below
		elsif @view == ZOrder::INFO
			@info_background_img.draw(0, 0, z = ZOrder::BACKGROUND)
			@back_button_img.draw(0, 0, ZOrder::TOP, 0.15, 0.15)
			@menu_font.draw_text("Information", 240, 15, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			Gosu.draw_rect(80, 120, 6, 6, Gosu::Color::FUCHSIA, ZOrder::TOP, mode=:default)
			@font.draw_text("A food, increases size by 1 and score by 10", 120, 110, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			Gosu.draw_rect(70, 160, 25, 25, Gosu::Color::GREEN, ZOrder::TOP, mode=:default)
			@font.draw_text("Super food, increases size by 10 and score by 100", 120, 165,ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@arrow_key_img.draw(300, 180, ZOrder::TOP, 1.0, 1.0)
			@font.draw_text("move up", 440, 240, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@font.draw_text("move left", 230, 300, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@font.draw_text("move right", 490, 300, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@font.draw_text("move down", 360, 350, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@shift_img.draw(60, 215, ZOrder::TOP, 0.2, 0.16)
			@font.draw_text("--Shift key--", 60, 310, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@font.draw_text("Increases speed", 60, 340, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@font.draw_text("Decreases size", 60, 370, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
		#if Z order is in CHAR, draw items below
		elsif @view == ZOrder::CHAR
			@color_background_img.draw(0, 0, ZOrder::BACKGROUND, 1, 1)
			@back_button_img.draw(0, 0, ZOrder::TOP, 0.15, 0.15)
			@menu_font.draw_text("Character Color", 200, 15, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@selected_img.draw(@selected_x, @selected_y, ZOrder::TOP, 0.0975, 0.0975)
			Gosu.draw_rect(140, 150, 50, 50, Gosu::Color::BLACK, ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(220, 150, 50, 50, Gosu::Color::GRAY, ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(300, 150, 50, 50, Gosu::Color::WHITE, ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(380, 150, 50, 50, Gosu::Color.argb(0xff_40E0D0), ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(460, 150, 50, 50, Gosu::Color::RED, ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(140, 220, 50, 50, Gosu::Color::GREEN, ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(220, 220, 50, 50, Gosu::Color::BLUE, ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(300, 220, 50, 50, Gosu::Color::YELLOW, ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(380, 220, 50, 50, Gosu::Color::FUCHSIA, ZOrder::MIDDLE, mode=:default)
			Gosu.draw_rect(460, 220, 50, 50, Gosu::Color::CYAN, ZOrder::MIDDLE, mode=:default)
		#if Z order is in LEADERBOARD, draw items below
		elsif @view == ZOrder::LEADERBOARD
			@color_background_img.draw(0, 0, ZOrder::BACKGROUND, 1, 1)
			@back_button_img.draw(0, 0, ZOrder::TOP, 0.15, 0.15)
			@menu_font.draw_text("Leaderboard", 230, 15, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			#draws ranking from 1 to 9
			@font.draw_text("1. #{@score_ranking[0]}" , 120, 110, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
			@font.draw_text("2. #{@score_ranking[1]}" , 120, 140, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
			@font.draw_text("3. #{@score_ranking[2]}" , 120, 170, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
			@font.draw_text("4. #{@score_ranking[3]}" , 120, 200, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
			@font.draw_text("5. #{@score_ranking[4]}" , 120, 230, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
			@font.draw_text("6. #{@score_ranking[5]}" , 120, 270, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
			@font.draw_text("7. #{@score_ranking[6]}" , 120, 300, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
			@font.draw_text("8. #{@score_ranking[7]}" , 120, 330, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
			@font.draw_text("9. #{@score_ranking[8]}" , 120, 370, ZOrder::TOP, 1.0, 1.0, Gosu::Color::RED)
		#if Z order is in BACKGROUND, draw items below
		elsif @view == ZOrder::BACKGROUND
			#draws a back button to go back to homepage
			@back_button_img.draw(0, 0, ZOrder::TOP, 0.15, 0.15)
			#draws background color
			@background_img.draw(0, 0, z = ZOrder::BACKGROUND)
			#draws character
			Gosu.draw_rect(@cordX, @cordY, @sizeX, @sizeY, @color, ZOrder::TOP, mode=:default)
			#display score points obtained
			@font.draw_text("Score: #{@score}", 10, 450, ZOrder::TOP, 1.0, 1.0, Gosu::Color::BLACK)
			@SPAWN_SUPER.spawn_super_food
			@pellet.each { |food| food.spawn_food }
			#if back button is clicked, calls the draw_confirmation function
			if @confirmation == true
				draw_confirmation
			end
		end
	end
	
	#returns an array with ranking order from highest to lowest
	def leaderboard_ranking_list
		score = Leaderboard.new(@score)        				#initialize leaderboard class
		array = score.display_leaderboard_ingame      		#extract the values from the score.txt file
		order = score_order(array)    						#rearrange the score from highest to lowest
		for x in 0..10
			@score_ranking << order[x]
		end
		return @score_ranking
	end
	
	#rearrange the score from highest to lowest
	def score_order(score)
		#highest = score[0]
		for i in 0..score.length-1
			for x in 0..score.length-1
				y=x+1
				if score[y].to_i > score[x].to_i
					score[x], score[y] = score[y], score[x]
				end
			end
		end
		return score
	end	
	
	#Draws a menu before entering the game
	def draw_menu
		if @view == ZOrder::MENU
			menu_font_text = "Press 'SpaceBar' To Play"
			menu_font_Xcord = 130
			menu_font_Ycord = 120
			menu_font_Zcord = ZOrder::MIDDLE
			@menu_font.draw_text(menu_font_text, menu_font_Xcord, menu_font_Ycord, menu_font_Zcord)
		end
	end
	
	#When normal foods are eaten, increases score
	def collect_food(all_food)
		@HsizeX = @sizeX / 2.0
		@HsizeY = @sizeY / 2.0
		@Char_half_width = @cordX + @HsizeX
		@Char_half_height = @cordY + @HsizeY
		all_food.reject! do |food|
			if Gosu::distance(@Char_half_width, @Char_half_height, food.ranX, food.ranY) <= @HsizeX+3
				@sizeX +=1
				@sizeY +=1
				@score +=10
				true
			else
			    false
			end
		end
    end

	#when super food eaten, return boolean to allow a new spawn and increases score
	def super_food_eaten
		@HsizeX = @sizeX / 2.0
		@HsizeY = @sizeY / 2.0
		@Char_half_width = @cordX + @HsizeX
		@Char_half_height = @cordY + @HsizeY
		if Gosu::distance(@Char_half_width, @Char_half_height, @SPAWN_SUPER.super_ranX, @SPAWN_SUPER.super_ranY) < @HsizeX+5
			@value2 = true
			return @value2
		else
			return @value2
		end
	end
	
	#generates new food 
	def generate_food
		Food.new(self)
	end
	
		
	#when cursor is on info button in homepage, return true
	def mouse_over_button_info?(mouse_x, mouse_y)
		if ((mouse_x > 280 and mouse_x < 375) and (mouse_y > 320 and mouse_y < 360))
			true
		else
			false
		end
	end
	
	#when cursor is on character color button in homepage, return true
	def mouse_over_button_char?(mouse_x, mouse_y)
		if ((mouse_x > 280 and mouse_x < 375) and (mouse_y > 370 and mouse_y < 410))
			true
		else
			false
		end
	end
	
	#when cursor is on leaderboard(score) button in homepage, return true
	def mouse_over_button_leaderboard?(mouse_x, mouse_y)
		if ((mouse_x > 280 and mouse_x < 375) and (mouse_y > 420 and mouse_y < 460))
			true
		else
			false
		end
	end
	
	#when cursor is on the back button in any page, return true
	def mouse_over_back_button?(mouse_x, mouse_y)
		if ((mouse_x > 0 and mouse_x < 25 ) and (mouse_y > 0 and mouse_y < 25))
			true
		else
			false
		end
	end
	
	#when cursor is on the green button on the ZOrder::BUTTON, return true
	def mouse_over_yes?(mouse_x, mouse_y)
		if ((mouse_x > 320 and mouse_x < 380 ) and (mouse_y > 280 and mouse_y < 320))
			true
		else
			false
		end
	end
	
	#when cursor is on the red button on the ZOrder::BUTTON, return true
	def mouse_over_no?(mouse_x, mouse_y)
		if ((mouse_x > 250 and mouse_x < 310 ) and (mouse_y > 280 and mouse_y < 320))
			true
		else
			false
		end
	end
	
	#when cursor is on any of the color palette button in character color page, return true
	def mouse_over_button_color?(mouse_x, mouse_y)
		if ((mouse_x > 140 and mouse_x < 190 ) and (mouse_y > 150 and mouse_y < 200))
			true
		elsif ((mouse_x > 220 and mouse_x < 270 ) and (mouse_y > 150 and mouse_y < 200))
			true
		elsif ((mouse_x > 300 and mouse_x < 350 ) and (mouse_y > 150 and mouse_y < 200))
			true
		elsif ((mouse_x > 380 and mouse_x < 430 ) and (mouse_y > 150 and mouse_y < 200))
			true
		elsif ((mouse_x > 460 and mouse_x < 510 ) and (mouse_y > 150 and mouse_y < 200))
			true
		elsif ((mouse_x > 140 and mouse_x < 190 ) and (mouse_y > 220 and mouse_y < 270))
			true
		elsif ((mouse_x > 220 and mouse_x < 270 ) and (mouse_y > 220 and mouse_y < 270))
			true
		elsif ((mouse_x > 300 and mouse_x < 350 ) and (mouse_y > 220 and mouse_y < 270))
			true
		elsif ((mouse_x > 380 and mouse_x < 430 ) and (mouse_y > 220 and mouse_y < 270))
			true
		elsif ((mouse_x > 460 and mouse_x < 510 ) and (mouse_y > 220 and mouse_y < 270))
			true
		else
			false
		end
	end
	
	#changes the character color to the color user picked
	def color_pick(mouse_x, mouse_y)
		if ((mouse_x > 140 and mouse_x < 190 ) and (mouse_y > 150 and mouse_y < 200))
			@color = @pick_color.black
		elsif ((mouse_x > 220 and mouse_x < 270 ) and (mouse_y > 150 and mouse_y < 200))
			@color = @pick_color.gray
		elsif ((mouse_x > 300 and mouse_x < 350 ) and (mouse_y > 150 and mouse_y < 200))
			@color = @pick_color.white
		elsif ((mouse_x > 380 and mouse_x < 430 ) and (mouse_y > 150 and mouse_y < 200))
			@color = @pick_color.turquoise
		elsif ((mouse_x > 460 and mouse_x < 510 ) and (mouse_y > 150 and mouse_y < 200))
			@color = @pick_color.red
		elsif ((mouse_x > 140 and mouse_x < 190 ) and (mouse_y > 220 and mouse_y < 270))
			@color = @pick_color.green
		elsif ((mouse_x > 220 and mouse_x < 270 ) and (mouse_y > 220 and mouse_y < 270))
			@color = @pick_color.blue
		elsif ((mouse_x > 300 and mouse_x < 350 ) and (mouse_y > 220 and mouse_y < 270))
			@color = @pick_color.yellow
		elsif ((mouse_x > 380 and mouse_x < 430 ) and (mouse_y > 220 and mouse_y < 270))
			@color = @pick_color.fuchsia
		elsif ((mouse_x > 460 and mouse_x < 510 ) and (mouse_y > 220 and mouse_y < 270))
			@color = @pick_color.cyan
		end
		return @color
	end
	
	#return the coordinates of the color picked, and use the coordinates to display a THUMBS UP image on top
	def selected_color
		if @color == @pick_color.black
			@selected_x = 140
			@selected_y = 150
		elsif @color == @pick_color.gray
			@selected_x = 220
			@selected_y = 150
		elsif @color == @pick_color.white
			@selected_x = 300
			@selected_y = 150
		elsif @color == @pick_color.turquoise
			@selected_x = 380
			@selected_y = 150
		elsif @color == @pick_color.red
			@selected_x = 460
			@selected_y = 150
		elsif @color == @pick_color.green
			@selected_x = 140
			@selected_y = 220
		elsif @color == @pick_color.blue
			@selected_x = 220
			@selected_y = 220
		elsif @color == @pick_color.yellow
			@selected_x = 300
			@selected_y = 220
		elsif @color == @pick_color.fuchsia
			@selected_x = 380
			@selected_y = 220
		elsif @color == @pick_color.cyan
			@selected_x = 460
			@selected_y = 220
		end
		return @selected_x, @selected_y
	end
	
	#draws a confirmation alert box that allows the user to decide if they want to quit and record their score or continue playing
	def draw_confirmation
		Gosu.draw_rect(170, 180, 300, 150, Gosu::Color::CYAN, ZOrder::POPUP, mode=:default)
		@font.draw_text("Scores will be recorded and reset" , 180, 200, ZOrder::BUTTON, 1.0, 1.0, Gosu::Color::BLACK)
		@font.draw_text("Are you sure?" , 250, 230, ZOrder::BUTTON, 1.0, 1.0, Gosu::Color::BLACK)
		Gosu.draw_rect(250, 280, 60, 40, Gosu::Color::RED, ZOrder::POPUP, mode=:default)
		Gosu.draw_rect(320, 280, 60, 40, Gosu::Color::GREEN, ZOrder::POPUP, mode=:default)
	end
	
	#when button down, do according to ZOrder layer and coordinates clicked on
	def button_down(id)
		case id
		when Gosu::MsLeft
			#Access info page	
			if @view == ZOrder::MENU and mouse_over_button_info?(mouse_x, mouse_y)
				@view = ZOrder::INFO
			#Return to menu from info page
			elsif @view == ZOrder::INFO and mouse_over_back_button?(mouse_x, mouse_y)
				@view = ZOrder::MENU
			elsif @view == ZOrder::MENU and mouse_over_button_char?(mouse_x, mouse_y)
				@view = ZOrder::CHAR
			elsif @view == ZOrder::CHAR and mouse_over_back_button?(mouse_x, mouse_y)
				@view = ZOrder::MENU
			elsif @view == ZOrder::CHAR and mouse_over_button_color?(mouse_x, mouse_y)
				color_pick(mouse_x, mouse_y)
			elsif @view == ZOrder::MENU and mouse_over_button_leaderboard?(mouse_x, mouse_y)
				@view = ZOrder::LEADERBOARD
			elsif @view == ZOrder::LEADERBOARD and mouse_over_back_button?(mouse_x, mouse_y)
				@view = ZOrder::MENU
			elsif @view == ZOrder::BACKGROUND and mouse_over_back_button?(mouse_x, mouse_y)
				@confirmation = true
			elsif @view == ZOrder::BACKGROUND and @confirmation == true 
				#if true, record score and reset game, go back to main menu page
				if mouse_over_yes?(mouse_x, mouse_y)      
						score = Leaderboard.new(@score)
						score.main
						@cordX = 280
						@cordY = 200
						@sizeX = 50.0
						@sizeY = 50.0
						@speed = 1
						@score = 500
						@view = ZOrder::MENU
						@confirmation = false
				#if true, stay on the same page and do nothing
				elsif mouse_over_no?(mouse_x, mouse_y)
						@view = ZOrder::BACKGROUND
						@confirmation = false
				end				
			end
		end
	end	
end

GameWindow.new.show

