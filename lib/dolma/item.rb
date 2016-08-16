module Dolma
  class Item < Base
    def self.fields
      [:description, :owners]
    end

    def description
      description = name_without_mentions
      description = checkmark + description if complete?
      description
    end

    def owners
      mentions.join(", ")
    end

    def color
      :green if complete?
    end

    def assign(card, list, owner)
      return if mentions.include?(owner)
      client.put("/cards/#{card.id}/checklist/#{list.id}/checkItem/#{id}/name", value: name_without_mentions + " @#{owner}")
    end

    private

      def mentions
        name.scan(/(@\S+)/).flatten
      end

      def name_without_mentions
        str = name
        mentions.each do |mention|
          str = str.gsub(mention, "")
        end
        str
      end

      def checkmark
        "\u2713 "
      end
  end
end
