#
# Check whether a user is ready for a new trust level.
#
class Promotion

  def initialize(user)
    @user = user
  end

  # Review a user for a promotion. Delegates work to a review_#{trust_level} method.
  # Returns true if the user was promoted, false otherwise.
  def review
    # nil users are never promoted
    return false if @user.blank?

    trust_key = TrustLevel.level_key(@user.trust_level)

    review_method = :"review_#{trust_key.to_s}"
    return send(review_method) if respond_to?(review_method)

    false
  end

  def review_new
    return false if @user.topics_entered < SiteSetting.basic_requires_topics_entered
    return false if @user.posts_read_count < SiteSetting.basic_requires_read_posts
    return false if (@user.time_read / 60) < SiteSetting.basic_requires_time_spent_mins

    @user.trust_level = TrustLevel.Levels[:basic]
    @user.save

    true
  end

end
