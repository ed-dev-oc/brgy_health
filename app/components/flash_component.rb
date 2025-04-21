# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  def initialize(flash:)
    @flash = flash
  end

  def icon(type)
    case type.to_s
    when "alert", "error"
      "bi-exclamation-diamond-fill"
    else
      "bi-check-lg"
    end
  end

  def css_class(type)
    "flash #{type} position-fixed top-0 end-0 text-light m-1 px-3 py-2 rounded shadow"
  end
end
