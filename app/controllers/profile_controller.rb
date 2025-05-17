class ProfileController < ApplicationController

    def edit
    @user = current_user
    render "pages/profile"
  end

end
