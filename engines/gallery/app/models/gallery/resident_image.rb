# frozen_string_literal: false

module Gallery
  class ResidentImage < Image

    belongs_to :resident, -> { select('residents.id, residents.user_id, residents.name, residents.slug') }

    has_one :user,
            -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
            :through => :resident,
            :source => :user,
            :class_name => "User"

    validates :resident_id, presence: true

    has_attached_file :file,
      styles: { :thumb => {:geometry =>'200x200>'}, :medium => {:geometry =>'400x400>'} },
      :path => 'gallery/residents/:part_id/:resident_id/images/:id/:style.:extension'

    process_in_background :file, url_with_processing: false

    validates :resident_id, presence: true

    validates :file, presence: true
    validates_attachment_size :file, :in => 0..1.megabyte
    validates_attachment_content_type :file, :content_type => %w(image/jpeg image/jpg image/png image/gif)

  end
end
