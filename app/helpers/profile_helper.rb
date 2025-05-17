module ProfileHelper
    def display_profile_image(user)
    if user.profile.attached?
      image_tag url_for(@user.profile.variant(resize_to_limit: [ 200, 200 ]).processed), alt: "Avatar"
    else
      image_tag "default_avatar.jpg", alt: alt, class: "rounded"
    end
  end
end
