class Bulletin < ActiveRecord::Base
  include Slugify

  attr_accessible :body, :title, :url, :bulletin_type, :user_id, :slug, :is_dead, :shortened_url, :score, :high_score, :expired, :expiration_date, :author_id, :author_type
  before_save :normalize_title
  before_save :nullify_body, :if => :is_link?
  before_create :create_slug, :create_shortened_url, :set_expiration_date

  has_many :votes, :as => :votable, :dependent => :destroy

  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :user
  belongs_to :author, polymorphic: true
  # bulletin_types:
  # post is 1
  # link is 2

  validates_presence_of :title
  validates_presence_of :body, :if => :is_post?
  validates_presence_of :url, :if => :is_link?
  validates_presence_of :user_id
  validates_presence_of :author_id
  validates_uniqueness_of :url, :allow_nil => true, :allow_blank => true

  scope :alive, where(expired: false)
  scope :has_author, conditions: 'author_id IS NOT NULL'

  def self.find_by_title(title)
    Bulletin.where("lower(title) = lower(:title)", :title => title).first
  end

  def expire
    val = should_be_expired?
    bulletin.update_attributes(expired: val)
  end

  def update_score
    scorekeeper = BulletinScoreKeeper.new(self)
    scorekeeper.update_score
  end

  def should_be_expired?
    self.expiration_date.to_date <= Date.current.to_date
  end

  def is_link?
    bulletin_type == 2
  end

  def is_post?
    bulletin_type == 1
  end

  def self.homepage
    Bulletin.where(is_dead: false).order("score DESC")
  end

  # TODO this should be using an additional scope
  def self.recent
    Bulletin.where(is_dead: false).order("score DESC").each_slice(10).to_a
  end

  def relative_local_url
    url.present? ? url : "#/bulletins/#{slug}"
  end

  def url_to_serialize
    Rails.env.production? ? shortened_url : relative_local_url
  end

  def promote
    orgs = Organization.reachable
    orgs.each do |org|
      OrganizationMailer.bulletin_promotion(self, org).deliver
    end
  end

  def voted_by_user?(user)
    votes.map(&:user_id).include? user.id
  end

  def author_is_admin?
    org = Organization.where(name: "CollegeDesis").first
    user.memberships.map(&:organization_id).include?(org.id) if org
  end

  def tweet
    tweeter = BulletinTweeter.new(self)
    tweeter.tweet
  end

  def approved?
    user.approved?
  end

  private

  def nullify_body
    self.body = nil
  end

  def create_shortened_url
    if Rails.env.production?
      client = Bitly.client
      to_shorten = if self.is_post?
        "https://collegedesis.com/" + relative_local_url
      else
        relative_local_url
      end
      self.shortened_url = client.shorten(to_shorten).short_url
    end
  end

  def normalize_title
    if title == title.upcase || title == title.downcase
      self.title = title.split.map(&:capitalize).join(' ')
    end
  end

  def set_expiration_date
    if !self.expiration_date
      if self.created_at?
        self.expiration_date = self.created_at + 2.days
      else
        self.expiration_date = Date.current + 2.days
      end
    end
  end
end
