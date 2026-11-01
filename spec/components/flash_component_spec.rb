# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashComponent, type: :component do
  it "renders a success flash with correct icon, close button, and class" do
    render_inline(described_class.new(flash: { notice: "Success message" }))

    expect(page).to have_css("div.flash.notice")
    expect(page).to have_text("Success message")
    expect(page).to have_css("i.bi.bi-check-lg")
    expect(page).to have_css("button.flash-close-btn")
  end

  it "renders an error flash with correct icon, close button, and class" do
    render_inline(described_class.new(flash: { error: "Error occurred" }))

    expect(page).to have_css("div.flash.error")
    expect(page).to have_text("Error occurred")
    expect(page).to have_css("i.bi.bi-exclamation-diamond-fill")
    expect(page).to have_css("button.flash-close-btn")
  end

  it "renders an alert flash with correct icon, close button, and class" do
    render_inline(described_class.new(flash: { alert: "Warning" }))

    expect(page).to have_css("turbo-frame#flash")
    expect(page).to have_css("div.flash.alert")
    expect(page).to have_text("Warning")
    expect(page).to have_no_text("</div>")
    expect(page).to have_css("i.bi.bi-exclamation-diamond-fill")
    expect(page).to have_css("button.flash-close-btn")
  end
end
