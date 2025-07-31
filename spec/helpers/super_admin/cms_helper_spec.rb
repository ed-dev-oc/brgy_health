require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SuperAdmin::CmsHelper. For example:
#
# describe SuperAdmin::CmsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SuperAdmin::CmsHelper, type: :helper do
  describe '#main_view_page_helper' do
    it 'returns root_path if section is homepage_hero_banner' do
      expect(helper).to receive(:root_path).and_return('/root')
      expect(helper.main_view_page_helper('homepage_hero_banner')).to eq('/root')
    end

    it 'returns main_page_path with section for other sections' do
      expect(helper).to receive(:main_page_path).with('about').and_return('/main/about')
      expect(helper.main_view_page_helper('about')).to eq('/main/about')
    end
  end
end
