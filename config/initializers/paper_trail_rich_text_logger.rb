Rails.application.config.to_prepare do
  ActionText::RichText.class_eval do
    after_update :log_body_change_for_papertrail

    def log_body_change_for_papertrail
      return unless saved_change_to_body?
      return unless %w[Page Announcement].include?(record_type)

      model = record_type.constantize.find_by(id: record_id)
      return unless model

      field_name = name

      version = PaperTrail::Version.new(
        item: model,
        event: "update",
        whodunnit: PaperTrail.request.whodunnit
      )

      version.object_changes = {
        field_name => [ saved_change_to_body.first.to_s, saved_change_to_body.last.to_s ]
      }.to_yaml

      version.save!
    end
  end
end
