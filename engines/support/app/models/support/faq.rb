module Support
  class Faq < ApplicationRecord

    scope :active, -> { where(active: 'true') }

    has_many :core_faqs, :dependent => :destroy

    validates :topic, length: { maximum: 255 }
    validates :question, presence: true, length: { maximum: 255 }
    validates :answer, length: { maximum: 24000 }

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
