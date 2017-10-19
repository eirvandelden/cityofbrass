module Gallery
  class ProprietaryImage < Image

    has_attached_file :file,
      styles: { :thumb => {:geometry =>'200x200>'}, :medium => {:geometry =>'400x400>'} },
      :path => 'gallery/stock-images/:id/:style.:extension'

    process_in_background :file, url_with_processing: false

    validates :file, presence: true
    validates_attachment_size :file, :in => 0..2.megabyte
    validates_attachment_content_type :file, :content_type => %w(image/jpeg image/jpg image/png image/gif)

  end
end
