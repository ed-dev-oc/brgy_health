require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Admin::CmsHelper. For example:
#
# describe Admin::CmsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Admin::CmsHelper, type: :helper do
  describe '#barangay_view_page_helper' do
    it 'returns root_path if section is homepage_hero_banner' do
      expect(helper).to receive(:root_path).and_return('/root')
      expect(helper.barangay_view_page_helper('homepage_hero_banner')).to eq('/root')
    end

    it 'returns about_us_pages_path if section is about_us' do
      expect(helper).to receive(:about_us_pages_path).and_return('/about_us')
      expect(helper.barangay_view_page_helper('about_us')).to eq('/about_us')
    end

    it 'returns contact_us_pages_path if section is contact_us' do
      expect(helper).to receive(:contact_us_pages_path).and_return('/contact_us')
      expect(helper.barangay_view_page_helper('contact_us')).to eq('/contact_us')
    end

    it 'returns nil for unknown section' do
      expect(helper.barangay_view_page_helper('other')).to be_nil
    end
  end
end
