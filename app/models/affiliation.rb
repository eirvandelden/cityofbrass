class Affiliation < ApplicationRecord
  belongs_to :resident
  belongs_to :affiliate, :class_name => "Resident", :foreign_key => "affiliate_id"

  has_many :contributors, :class_name => "Worldbuilder::Contributor", :dependent => :destroy
  has_many :players,      :class_name => "Campaignmanager::Player", :dependent => :destroy

  has_one :resident_user,
          -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
          :through => :affiliate,
          :source => :user,
          :class_name => "User"

  has_one :affiliate_user,
          -> { select('users.id, email, status').where(status: User::ACTIVE_STATUS) },
          :through => :resident,
          :source => :user,
          :class_name => "User"

  validates :resident_id,  presence: true
  validates :affiliate_id, presence: true

  def self.are_affiliates(resident, affiliate)
    return false if resident == affiliate
    return true unless find_by(resident_id: resident.id, affiliate_id: affiliate.id, status: 'accepted').nil?
    return true unless find_by(resident_id: affiliate.id, affiliate_id: resident.id, status: 'accepted').nil?
    false
  end

  def self.has_affiliation (resident, affiliate)
    return true if resident == affiliate
    return true unless find_by(resident_id: resident.id, affiliate_id: affiliate.id).nil?
    return true unless find_by(resident_id: affiliate.id, affiliate_id: resident.id).nil?
    false
  end

  def self.request(resident, affiliate)
    return false if resident == affiliate
    return false if has_affiliation(resident, affiliate)
    f1 = new(:resident => resident, :affiliate => affiliate, :status => "pending")
    f2 = new(:resident => affiliate, :affiliate => resident, :status => "requested")
    transaction do
      f1.save
      f2.save
    end
    return true
  end

  def self.accept(resident, affiliate)
    f1 = find_by(resident_id: resident.id, affiliate_id: affiliate.id)
    f2 = find_by(resident_id: affiliate.id, affiliate_id: resident.id)
    if f1.nil? or f2.nil?
      return false
    else
      transaction do
        f1.update_attributes(:status => "accepted")
        f2.update_attributes(:status => "accepted")
      end
    end
    return true
  end

  def self.reject(resident, affiliate)
    f1 = find_by(resident_id: resident.id, affiliate_id: affiliate.id)
    f2 = find_by(resident_id: affiliate.id, affiliate_id: resident.id)
    if f1.nil? or f2.nil?
      return false
    else
      transaction do
        f1.destroy
        f2.destroy
      end
    end
    return true
  end

  def self.block(resident, affiliate)
    f1 = find_by(resident_id: resident.id, affiliate_id: affiliate.id)
    f2 = find_by(resident_id: affiliate.id, affiliate_id: resident.id)
    if f1.nil? or f2.nil?
      return false
    else
      transaction do
        f1.update_attributes(:status => "blocked")
        f2.update_attributes(:status => "hidden")
      end
    end
    return true
  end

end
