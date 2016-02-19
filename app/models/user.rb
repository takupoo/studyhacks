class User < ActiveRecord::Base

   has_attached_file :avatar,
                      styles:  { medium: "300x300#", thumb: "100x100#" }
  validates_attachment_content_type :avatar,
                                      content_type: ["image/jpg","image/jpeg","image/png"]

  has_many :authentications

  private

  # ユーザ作成
  def self.create_with_auth(authentication, request)
    # ユーザ作成
    user = User.new
    user.name                = (authentication.nickname.presence || authentication.name)
    user.image               = authentication.image    if authentication.image.present?
    user.email               = authentication.email    if authentication.email.present?
    user.last_login_provider = authentication.provider if authentication.provider.present?
    user.last_login_at       = Time.now
    user.user_agent          = request.env['HTTP_USER_AGENT'] rescue 'error'

    # データ保存
    user.save!

    # auth紐付け
    authentication.user_id = user.id
    authentication.save!

    return user
  end
end
