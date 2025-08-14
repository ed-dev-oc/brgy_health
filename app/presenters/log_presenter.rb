class LogPresenter
  def initialize(log)
    @log = log
  end

  def timestamp
    @log.created_at.in_time_zone("Asia/Manila").strftime("%B %d, %Y %I:%M %p")
  end

  def user_name
    if @log.is_a?(PaperTrail::Version)
      User.find_by(id: @log.whodunnit)&.full_name || "System"
    elsif @log.is_a?(AnnouncementView) && @log.user.present?
      @log.user.full_name
    elsif @log.is_a?(AnnouncementView)
      "Guest (IP: #{@log.ip_address})"
    else
      "System"
    end
  end

  def event_type
    if @log.is_a?(PaperTrail::Version)
      @log.event
    elsif @log.is_a?(AnnouncementView)
      "view"
    else
      "unknown"
    end
  end

  def changeset
    return {} unless @log.is_a?(PaperTrail::Version) && @log.object_changes.present?

    YAML.safe_load(
      @log.object_changes,
      permitted_classes: [Time, Date, Symbol, ActiveSupport::TimeWithZone, ActiveRecord::Type::Time::Value],
      aliases: true
    ).symbolize_keys
  rescue Psych::DisallowedClass
    {}
  end

  def special_field_label(field)
    case field.to_s
    when "description"
      "Description Updated"
    else
      "#{field.to_s.humanize} Updated"
    end
  end

  def field_change_details(field, old_val, new_val)
    case field.to_s
    when "description"
      "Description content was updated."
    when "status"
      old_label = Announcement.statuses.key(old_val.to_i)&.humanize || old_val
      new_label = Announcement.statuses.key(new_val.to_i)&.humanize || new_val
      "Status changed from <strong>#{old_label}</strong> to <strong>#{new_label}</strong>".html_safe
    when "health_program_id"
      old_name = HealthProgram.find_by(id: old_val)&.name || "Unknown"
      new_name = HealthProgram.find_by(id: new_val)&.name || "Unknown"
      "Health Program changed from <strong>#{old_name}</strong> to <strong>#{new_name}</strong>".html_safe
    else
      formatted_old = format_time_or_value(old_val)
      formatted_new = format_time_or_value(new_val)
      "Changed from <strong>#{formatted_old}</strong> to <strong>#{formatted_new}</strong>".html_safe
    end
  end

  def image_updated?
    changeset.key?(:image_updated_at)
  end

  private

  def format_time_or_value(value)
    Time.parse(value.to_s).in_time_zone("Asia/Manila").strftime("%B %d, %Y %I:%M %p")
  rescue
    value
  end
end
