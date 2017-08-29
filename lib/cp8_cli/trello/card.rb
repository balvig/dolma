module Cp8Cli
  module Trello
    class Card < Base
      belongs_to :board, foreign_key: "idBoard"

      def self.fields
        [:title]
      end

      def self.find_by_url(url)
        card = Card.new(url: url)
        find(card.short_link)
      end

      def title
        name
      end

      def pr_title
        "#{title} [Delivers ##{short_link}]"
      end

      def summary
        "Trello: #{short_url}"
      end

      def start
        move_to board.lists.started
      end

      def finish
        move_to board.lists.finished
      end

      def accept
        move_to board.lists.accepted
      end

      def assign(user)
        return if member_ids.include?(user.trello_id)
        self.class.request(:post, "cards/#{id}/members", value: user.trello_id)
      end

      def add_label(label)
        self.class.request(:post, "cards/#{id}/idLabels", value: label.id)
      end

      def attach(url:)
        self.class.request(:post, "cards/#{id}/attachments", url: url)
      end

      def short_link
        url.scan(/\/c\/(.+)\//).flatten.first
      end

      def short_url
        attributes[:shortUrl]
      end

      private

        def move_to(list)
          self.class.with("cards/:id/idList").where(id: id, value: list.id).put
        end

        def member_ids
          attributes["idMembers"] || []
        end
    end
  end
end