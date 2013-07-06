class User < ActiveRecord::Base
  concerned_with :states, :activation, :posting, :validation
  formats_attributes :bio

  belongs_to :site, :counter_cache => true
  belongs_to :level
  has_many :events, :dependent => :destroy
  has_many :achievements

  validates_presence_of :site_id

  has_many :posts, :order => "#{Post.table_name}.created_at desc"
  has_many :topics, :order => "#{Topic.table_name}.created_at desc"

  has_many :moderatorships, :dependent => :delete_all
  has_many :forums, :through => :moderatorships, :source => :forum do
    def moderatable
      select("#{Forum.table_name}.*, #{Moderatorship.table_name}.id as moderatorship_id")
    end
  end

  has_many :monitorships, :dependent => :delete_all
  has_many :monitored_topics, :through => :monitorships, :source => :topic, :conditions => {"#{Monitorship.table_name}.active" => true}

  extend FriendlyId
  friendly_id :login, :use => :scoped, :slug_column => :permalink, :scope => :site

  attr_readonly :posts_count, :last_seen_at
  after_create :award_signup_points

  scope :named_like, lambda { |name| where("users.display_name like ? or users.login like ?", "#{name}%", "#{name}%") }
  scope :online, lambda { where("users.last_seen_at >= ?", 10.minutes.ago.utc) }

  class << self

    def prefetch_from(records)
      select("distinct *").where(:id => records.collect(&:user_id).uniq)
    end

    def index_from(records)
      prefetch_from(records).index_by(&:id)
    end

  end


  def available_forums
    @available_forums ||= site.ordered_forums - forums
  end

  def moderator_of?(forum)
    !!(admin? || Moderatorship.exists?(:user_id => id, :forum_id => forum.id))
  end

  def display_name
    n = read_attribute(:display_name)
    n.blank? ? login : n
  end

  alias_method :to_s, :display_name

  # this is used to keep track of the last time a user has been seen (reading a topic)
  # it is used to know when topics are new or old and which should have the green
  # activity light next to them
  #
  # we cheat by not calling it all the time, but rather only when a user views a topic
  # which means it isn't truly "last seen at" but it does serve it's intended purpose
  #
  # This is now also used to show which users are online... not at accurate as the
  # session based approach, but less code and less overhead.
  def seen!
    now = Time.now.utc
    self.class.where(:id => id).update_all(:last_seen_at => now)
    write_attribute(:last_seen_at, now)
    award_login_bonus!
  end

  def to_param
    id.to_s # permalink || login
  end

  def openid_url=(value)
    write_attribute :openid_url, value.blank? ? nil : OpenIdAuthentication.normalize_identifier(value)
  end

  def using_openid
    self.openid_url.blank? ? false : true
  end

  def to_xml(options = {})
    options[:except] ||= []
    options[:except] += [:email, :login_key, :login_key_expires_at, :password_hash, :openid_url, :activated, :admin]
    super
  end

  def add_points(new_points, event_string)
    update_score_and_level(new_points)
    log_event(new_points, event_string)
  end

  def deduct_points(new_points, event_string)
    add_points(-new_points, event_string)
  end

  def award_login_bonus!
    unless last_login_bonus_awarded_at &&
      last_login_bonus_awarded_at > 1.day.ago.utc
      add_points(LOGIN_BONUS, "로그인 보너스 지급!")
      write_attribute(:last_login_bonus_awarded_at, Time.now.utc)
    end
  end

  def award_badge(name)
    badge = Badge.fnid_by_name(name)
    unless achievements.find_by_badge_id(badge.id)
      achievements.create(:badge => badge)
    end
  end

  private
  def award_signup_points
    add_points(SIGNUP_BONUS, "야호! 가입 ㅊㅋㅊㅋ!")
  end

  def update_score_and_level(new_points)
    new_score = self.score += new_points
    self.update_attribute :score, new_score
    new_level = Level.fund_level_for_score(new_score)
    if new_level &&
      (!self.level || new_level.number > self.level.number)
      self.update_attribute(:level_id, new_level.id)
    end
  end
  def log_event(points, event_string)
    events.create(:points => points, :text => event_string)
  end
end
