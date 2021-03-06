# frozen_string_literal: true

class ArchiveImporter
  class ContactImporter
    include Diaspora::Logging

    def initialize(json, user)
      @json = json
      @user = user
    end

    attr_reader :json
    attr_reader :user

    def import
      return unless json.fetch("receiving")

      @imported_contact = create_contact
      add_to_aspects
    rescue ActiveRecord::RecordInvalid => e
      logger.warn "#{self}: #{e}"
    end

    private

    def add_to_aspects
      json.fetch("contact_groups_membership", []).each do |group_name|
        aspect = user.aspects.find_by(name: group_name)
        if aspect.nil?
          logger.warn "#{self}: aspect \"#{group_name}\" is missing"
          next
        end
        @imported_contact.aspects << aspect
      end
    end

    def create_contact
      person = Person.by_account_identifier(json.fetch("account_id"))
      # see AccountMigration#dispatch_contacts for the other half of this when the contact is sharing with the user
      user.contacts.create!(person_id: person.id, sharing: false, receiving: true)
    end
  end
end
