#!/usr/bin/env ruby
require 'yaml'
str = "testing with a random string"

def playingWithStrings(str)
    puts str.capitalize  #capitalize first letter
    puts str.upcase      #caps all
    puts str.downcase    #lower all
    puts str.reverse
    puts str.length
    puts str[2..6]
    puts str[9]         # print a specific char in the array
    var1 = 1
    var2 = '5'
    puts var1 + var2.to_i
    puts var1.to_s + var2
end

def playingWithConditions(str)
    if str.start_with?('a')  #available as of 1.9
        puts "starts with a 'a'"
    elsif str.match(/^tes/)  #regex works with all versions
        puts "starts with a 't'"
    elsif str.end_with?('s')
        puts "ends with a 's'"
    else
        puts "no idea"
    end
end

def playingWithLoopControls(str)
    count = 0
    while count <= 5 do
        if (count == 3)
            count += 1
            next  # skips the iteration and breaks out of the loop to the next iteration
        else
            puts count
        end
        count += 1
    end
end

def playingWithErrors(str)
    begin
        raise ArgumentError.new("Hmmm")
    end
end

def playingWithExceptions(str)
    x=0
    puts 1/x
    rescue ZeroDivisionError
    puts "you tried to divide by 0"
end

def playingWithUserInput()
    puts "give me a number: "
    some_number = gets
    puts "you gave me: " + some_number
    puts "what's your name? "
    name = gets.chomp
    puts "Your name is: " + name + ".  Nice to meet you"
end

def playingWithArrays()
    #my_array = ['10', 'Hello', [true, false]]
    my_array = ['10', 'Hello', "There"]
    my_array.push('again')
    puts my_array[2][0]
    my_array.each do |x|
        puts 'Element: ' + x
    end
    puts my_array.to_s
    puts my_array.join(' :: ')
end

def playingWithReturns()
    my_input = gets.chomp

    if my_input == 'foo'
        return 'I got foo'
    else
        puts "I got something else"
    end
end

def playingWithFiles()
    my_file = 'sandbox.txt'
    File.open my_file, 'r' do |f| #method 1
        puts f.read
    end
    read_string = File.read my_file #method 2
    puts read_string
end

def playingWithYaml()
    test_array = ['this', 'is', 'a', 'test', [0,1]]
    test_string = test_array.to_yaml
    puts test_string
end

playingWithYaml
#playingWithFiles
#playingWithReturns
#playingWithArrays()
#playingWithUserInput()
#playingWithExceptions(str)
#playingWithErrors(str)
#playingWithLoopControls(str)
#playingWithConditions(str)
#playingWithStrings(str)
$end #ending for good measure

