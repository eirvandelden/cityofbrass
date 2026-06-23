module Support
  class Faq < ApplicationRecord
    has_rich_text :answer

    scope :active, -> { where(active: 'true') }

    has_many :core_faqs, :dependent => :destroy

    validates :topic, length: { maximum: 255 }
    validates :question, presence: true, length: { maximum: 255 }

    def new_topic
      #topic
    end

    def new_topic=(t)
      if !t.blank?
        self.topic = t
      end
    end
  end
end
