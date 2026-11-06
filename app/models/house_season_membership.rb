# frozen_string_literal: true

class HouseSeasonMembership < ApplicationRecord
  belongs_to :house_season
  belongs_to :roommate
  has_one :user, through: :roommate
  enum :status, { active: 'active', former: 'former' }, prefix: true, validate: true
  validates :roommate_id, uniqueness: { scope: :house_season_id }
  validate :same_house
  before_validation :normalize_social_links
  validate :valid_social_links

  def shared_social_links
    social_links.select { |link| link['shared'] }
  end

  private

  def normalize_social_links
    return unless social_links.is_a?(Array)

    self.social_links = social_links.filter_map do |link|
      next unless link.is_a?(Hash)
      next if link['label'].blank? && link['url'].blank?

      { 'label' => link['label'].to_s.strip, 'url' => link['url'].to_s.strip,
        'shared' => ActiveModel::Type::Boolean.new.cast(link['shared']) == true }
    end
  end

  def valid_social_links
    unless social_links.is_a?(Array) && social_links.size <= 10
      errors.add(:social_links, 'must contain at most 10 links')
      return
    end

    social_links.each do |link|
      uri = URI.parse(link['url'])
      valid = link['label'].present? && link['label'].length <= 40 && uri.is_a?(URI::HTTPS) &&
        uri.host.present? && uri.userinfo.nil?
      errors.add(:social_links, 'need a name and a valid HTTPS URL without login credentials') unless valid
    rescue URI::InvalidURIError
      errors.add(:social_links, 'need a valid HTTPS URL')
    end
  end

  def same_house
    return if roommate && house_season && roommate.lodging_id == house_season.lodging_id && !roommate.guest?

    errors.add(:roommate, 'must be a roommate in this house')
  end
end
