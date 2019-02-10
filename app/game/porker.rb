class Poker
    def self.cards(deck_of_cards)
      @deck = deck_of_cards.ceil#取整數 無條件進位
      (0...@deck*52).map { |i| Poker.suit(i + 1) + Poker.symbol(i + 1)}
    end

    def self.suit(number)
      suit_case =[]
      (0..@deck).each{|n| suit_case[n]= 4*n}
        case (number - 1) / 13
            when *suit_case; "黑桃"
            when *suit_case.map{|x| x+1}; "紅心"
            when *suit_case.map{|x| x+2}; "方塊"
            when *suit_case.map{|x| x+3}; "梅花"
        end
    end
    
    def self.symbol(number)
        remain = number % 13
        case remain
            when 0;  "K "
            when 1;  "A "
            when 11; "J "
            when 12; "Q "
            else;sprintf("%-2d", remain)
        end
    end
    
    def self.shuffle(deck_of_cards)
      Poker.cards(deck_of_cards).sort_by{rand}
    end
end