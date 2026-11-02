# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  def initialize(flash:)
    @flash = flash
  end

  def icon(type)
    case type.to_s
    when "alert", "error", "danger"
      "bi-exclamation-diamond-fill"
    when "warning"
      "bi-exclamation-triangle-fill"
    else
      "bi-check-lg"
    end
  end

  def title(type)
    case type.to_s
    when "alert", "error", "danger"
      "Attention Needed"
    when "warning"
      "Warning"
    else
      "Success"
    end
  end

  def css_class(type)
    "flash #{type}"
  end
end
