# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class ExportUser < ArchiveBase
    private

    def perform_archive_job(user_id)
      user = User.find(user_id)
      user.perform_export!

      if user.reload.export.present?
        ExportMailer.export_complete_for(user).deliver_now
      else
        ExportMailer.export_failure_for(user).deliver_now
      end
    end
  end
end
