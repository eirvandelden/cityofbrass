class User < ApplicationRecord

  attr_accessor :check_field

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  STATUS_OPTIONS  = ['active', 'alpha', 'beta', 'trial', 'free', 'vip', 'locked', 'canceled']
  ACTIVE_STATUS   = ['active', 'alpha', 'beta', 'trial', 'free', 'vip']
  VIP_STATUS      = ['alpha', 'beta', 'vip', 'locked'] # <=== billing exempt

  scope :active, -> { where(status: ACTIVE_STATUS) }
  scope :order_email, -> { order(:email) }
  scope :order_status, -> { order(:status) }

  has_one :subscription, :class_name => "Billing::Subscription"
  has_one :resident

  validate :honeypot_absence, :on => :create

  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, presence: true, on: :create
  validates :password_confirmation, :presence => true, on: :create

  validates :terms_of_service, :acceptance => true, :on => :create
  after_validation :set_status, :on => :create

  validates :status, presence: true

  def honeypot_absence
    errors.add :check_field, "You should not fill in the invisible field" unless check_field.blank?
  end

  def active?
    return false unless status.present?
    return ACTIVE_STATUS.include? status
  end

  def is_free?
    return status == 'free'
  end

  def is_not_free?
    return status != 'free'
  end

  def inactive?
    return true unless status.present?
    return true unless ACTIVE_STATUS.include? status
    return false
  end

  def has_vip_status?
    return false unless status.present?
    return VIP_STATUS.include? status
  end

  def stripe_customer
    begin
      if stripe_customer_token.present?
        return Stripe::Customer.retrieve(self.stripe_customer_token)
      else
        customer = Stripe::Customer.create(:email => self.email)
        self.stripe_customer_token = customer.id
        save!
        return customer
      end
    rescue Stripe::StripeError => e
      logger.error "Stripe error while creating customer: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      return nil
    end
  end

  def self.search(search)
    joins("LEFT JOIN residents ON residents.user_id = users.id").where("email ilike ? or residents.name ilike ?", "%#{search}%", "%#{search}%")
  end

  def make_active
    unless self.has_vip_status?
      self.status = 'active'
      save!
    end
  end

  def self.trial_expiration_warning
    trials = User.select('id, email').where(["status = ? AND created_at > ? AND created_at < ?", :trial, 28.days.ago, 27.days.ago])

    trials.each do |user|
        UserMailer.user_trial_warning(user).deliver_later
    end

    puts "Emailing #{trials.size} trial(s) about to expire."
  end

  def self.cancel_trials
    trials = User.select('id, email').where(["status = ? AND created_at < ?", :trial, 30.days.ago])

    trials.each do |user|
        UserMailer.user_trial_end(user).deliver_later
    end

    puts "Canceling #{trials.size} expired trial(s)."
    User.where(["status = ? AND created_at < ?", :trial, 30.days.ago]).update_all(status: 'canceled')
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def trial_days_remaining
    days_used = (Time.now.to_date - self.created_at.to_date).to_i
    days_left = 31 - days_used
    return days_left if days_left > 0
    return 0
  end

  protected
    def set_status
      self.status = 'free'
    end

end
