require 'rails_helper'

describe ApplicationHelper, type: :helper do
  let(:user) { double('User', profile: profile, initials: 'AB', super_admin?: false, admin?: false) }
  let(:profile) { double('Profile') }

  describe '#navbar_link_status' do
    it 'returns active if current page' do
      allow(helper).to receive(:current_page?).with('/foo').and_return(true)
      expect(helper.navbar_link_status('/foo')).to eq('active')
    end
    it 'returns empty string if not current page' do
      allow(helper).to receive(:current_page?).with('/foo').and_return(false)
      expect(helper.navbar_link_status('/foo')).to eq('')
    end
  end

  describe '#icon_for_state' do
    it 'returns active_state if current page' do
      allow(helper).to receive(:current_page?).with('/bar').and_return(true)
      expect(helper.icon_for_state('/bar', 'on', 'off')).to eq('on')
    end
    it 'returns inactive_state if not current page' do
      allow(helper).to receive(:current_page?).with('/bar').and_return(false)
      expect(helper.icon_for_state('/bar', 'on', 'off')).to eq('off')
    end
  end

  describe '#administrator_path_helper' do
    it 'returns super_admin_dashboard_index_path for super_admin' do
      allow(helper).to receive(:current_user).and_return(double(super_admin?: true))
      expect(helper).to receive(:super_admin_dashboard_index_path).and_return('/super_admin')
      expect(helper.administrator_path_helper).to eq('/super_admin')
    end
    it 'returns admin_dashboard_index_path for admin' do
      allow(helper).to receive(:current_user).and_return(double(super_admin?: false))
      expect(helper).to receive(:admin_dashboard_index_path).and_return('/admin')
      expect(helper.administrator_path_helper).to eq('/admin')
    end
  end

  describe '#navbar_title' do
    it 'returns tenant name with Health Center if tenant present' do
      tenant = double(name: 'Foo')
      allow(ActsAsTenant).to receive(:current_tenant).and_return(tenant)
      expect(helper.navbar_title).to eq('Foo Health Center')
    end
    it 'returns default title if tenant not present' do
      allow(ActsAsTenant).to receive(:current_tenant).and_return(nil)
      expect(helper.navbar_title).to eq('Barangay Health Center')
    end
  end

  describe '#display_profile_image' do
    it 'returns image_tag with user profile if attached' do
      allow(user.profile).to receive(:attached?).and_return(true)
      variant = double(processed: :processed)
      allow(user.profile).to receive(:variant).with(resize_to_limit: [ 200, 200 ]).and_return(variant)
      allow(helper).to receive(:url_for).with(:processed).and_return('profile_url')
      expect(helper).to receive(:image_tag).with('profile_url', alt: 'Avatar', class: 'rounded')
      helper.display_profile_image(user)
    end
    it 'returns placeholder image if not attached' do
      allow(user.profile).to receive(:attached?).and_return(false)
      expect(helper).to receive(:image_tag).with(/placehold.co/, hash_including(:alt, :class, :style))
      helper.display_profile_image(user)
    end
  end

  describe '#profile_url' do
    it 'returns url_for profile if attached' do
      allow(user.profile).to receive(:attached?).and_return(true)
      variant = double(processed: :processed)
      allow(user.profile).to receive(:variant).with(resize_to_limit: [ 80, 80 ]).and_return(variant)
      allow(helper).to receive(:url_for).with(:processed).and_return('profile_url')
      expect(helper.profile_url(user)).to eq('profile_url')
    end
    it 'returns placeholder url if not attached' do
      allow(user.profile).to receive(:attached?).and_return(false)
      expect(helper.profile_url(user)).to match(/placehold.co/)
    end
  end

  describe '#back_button_for_user' do
    it 'returns link to super_admin_dashboard_index_path for super_admin' do
      allow(helper).to receive(:current_user).and_return(double(super_admin?: true, admin?: false))
      expect(helper).to receive(:super_admin_dashboard_index_path).and_return('/super_admin')
      expect(helper).to receive(:link_to).with('Back', '/super_admin', hash_including(:class))
      helper.back_button_for_user
    end
    it 'returns link to admin_dashboard_index_path for admin' do
      allow(helper).to receive(:current_user).and_return(double(super_admin?: false, admin?: true))
      expect(helper).to receive(:admin_dashboard_index_path).and_return('/admin')
      expect(helper).to receive(:link_to).with('Back', '/admin', hash_including(:class))
      helper.back_button_for_user
    end
    it 'returns link to root_path for other users' do
      allow(helper).to receive(:current_user).and_return(double(super_admin?: false, admin?: false))
      expect(helper).to receive(:root_path).and_return('/')
      expect(helper).to receive(:link_to).with('Back', '/', hash_including(:class))
      helper.back_button_for_user
    end
  end

  describe '#edit_profile_button' do
    it 'returns link to edit_profile_path' do
      expect(helper).to receive(:edit_profile_path).with(user).and_return('/edit')
      expect(helper).to receive(:link_to).with('Edit profile', '/edit', hash_including(:class))
      helper.edit_profile_button(user)
    end
    it 'returns link with custom label' do
      expect(helper).to receive(:edit_profile_path).with(user).and_return('/edit')
      expect(helper).to receive(:link_to).with('Custom', '/edit', hash_including(:class))
      helper.edit_profile_button(user, label: 'Custom')
    end
  end

  describe '#badge_status_class' do
    it 'returns correct class for each status' do
      expect(helper.badge_status_class('active')).to eq('text-bg-primary')
      expect(helper.badge_status_class('approved')).to eq('text-bg-success')
      expect(helper.badge_status_class('pending')).to eq('text-bg-warning')
      expect(helper.badge_status_class('rejected')).to eq('text-bg-danger')
      expect(helper.badge_status_class('draft')).to eq('text-bg-secondary')
      expect(helper.badge_status_class('feature_request')).to eq('text-bg-info')
      expect(helper.badge_status_class('unknown')).to eq('text-bg-secondary')
    end
  end
end
