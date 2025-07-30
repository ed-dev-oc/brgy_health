require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:barangay).optional }
    it { is_expected.to belong_to(:subdivision).optional }
    it { is_expected.to have_many(:announcements).with_foreign_key(:posted_by_id) }
    it { is_expected.to have_many(:appointments).with_foreign_key(:patient_id) }
    it { is_expected.to have_many(:appointments_as_health_worker).with_foreign_key(:health_worker_id).class_name('Appointment') }
    it { is_expected.to have_many(:notifications).class_name('Noticed::Notification') }
    it { is_expected.to have_many(:noticed_events).class_name('Noticed::Event').dependent(:destroy) }
    it { is_expected.to have_many(:about_me_notifications).through(:noticed_events).source(:notifications).class_name('Noticed::Notification') }
    it { is_expected.to have_many(:push_subscriptions) }
    it { is_expected.to have_one(:testimonial) }
    it { is_expected.to have_many(:events).with_foreign_key('posted_by_id').dependent(:destroy) }
    it { is_expected.to have_one_attached(:profile) }
  end

  describe 'validations' do
    subject { build(:user) }

    it "validates uniqueness of email" do
      create(:user, email: "unique@example.com")
      user = build(:user, email: "unique@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "validates uniqueness of public_uid with alpha chars" do
      create(:user, public_uid: "ABC123")
      expect(build(:user, public_uid: "ABC123")).not_to be_valid
    end

    it "validates uniqueness of phone_number with alpha chars" do
      create(:user, phone_number: "A09171234567")
      expect(build(:user, phone_number: "A09171234567")).not_to be_valid
    end

    it {
      is_expected.to validate_uniqueness_of(:first_name).scoped_to(:middle_name, :last_name, :suffix)
        .with_message('with this full name already exists')
    }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:role) }

    it "requires barangay unless super_admin" do
      ActsAsTenant.with_mutable_tenant do
        user = build(:user, role: :admin)
        user.barangay = nil
        user.barangay_id = nil

        expect(user).not_to be_valid
        expect(user.errors[:barangay]).to be_present

        super_admin = build(:user, role: :super_admin)
        super_admin.barangay = nil
        super_admin.barangay_id = nil

        expect(super_admin).to be_valid
      end
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values([ :super_admin, :admin, :staff, :patient ]) }
  end

  describe 'flags and callbacks' do
    let(:barangay) { create(:barangay) }
    let(:user) { build(:user, role: :admin, barangay: barangay, phone_number: nil, subdivision: nil) }

    it 'adds require_validation flag for admin before create' do
      user.save!
      expect(user.flag_list).to include('require_validation')
    end

    it 'adds requirements flags before create' do
      user.save!
      expect(user.flag_list).to include('no_phone_number', 'no_subdivision')
    end

    it 'removes requirements flags before update' do
      user.save!
      user.phone_number = '1234567890'
      user.subdivision = create(:subdivision, barangay: barangay)
      user.save!
      expect(user.flag_list).not_to include('no_phone_number', 'no_subdivision')
    end
  end

  describe 'custom methods' do
    it '#full_name returns the concatenated full name' do
      user = build(:user, first_name: 'John', middle_name: 'A', last_name: 'Doe', suffix: 'Jr.')
      expect(user.full_name).to eq('John A Doe Jr.')
    end

    it '#notification_channel returns the correct notification channel' do
      user = build(:user, public_uid: '12345')
      expect(user.notification_channel).to eq('user_12345_notification')
    end

    it '#initials returns the initials' do
      user = build(:user, first_name: 'Jane', last_name: 'Smith')
      expect(user.initials).to eq('JS')
    end
  end

  describe 'Devise modules' do
    it 'includes Devise modules' do
      expect(User.devise_modules).to include(:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable)
    end
  end

  describe 'super_admin demotion protection' do
    it 'prevents demotion of super_admin' do
      user = create(:user, role: :super_admin)
      user.role = :admin
      expect(user.save).to be_falsey
      expect(user.errors[:role]).to include('cannot be changed for super admin')
    end
  end

  describe 'credential change notification' do
    it 'notifies user when credentials change' do
      user = create(:user, role: :patient)
      allow(UserCredentialChangedNotifier).to receive_message_chain(:with, :deliver_later)
      user.update(email: 'newemail@example.com')
      expect(UserCredentialChangedNotifier).to have_received(:with)
    end
  end

  describe 'edge cases' do
    it 'does not require barangay for super_admin' do
      user = build(:user, role: :super_admin, barangay: nil)
      expect(user).to be_valid
    end

    it 'requires barangay for admin' do
      ActsAsTenant.with_mutable_tenant do
        user = build(:user, role: :admin)
        user.barangay = nil
        expect(user).not_to be_valid
        expect(user.errors[:barangay]).to be_present
      end
    end

    it 'adds no_subdivision flag if subdivision is nil and not super_admin' do
      user = build(:user, role: :staff, subdivision: nil)
      user.save!
      expect(user.flag_list).to include('no_subdivision')
    end

    it 'adds no_phone_number flag if phone_number is nil' do
      user = build(:user, phone_number: nil)
      user.save!
      expect(user.flag_list).to include('no_phone_number')
    end
  end
end
