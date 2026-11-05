# frozen_string_literal: true

module ApplicationHelper
  AVATAR_HEIGHTS = { '6' => 'h-6', '8' => 'h-8', '10' => 'h-10', '12' => 'h-12', '14' => 'h-14', '16' => 'h-16' }.freeze
  AVATAR_WIDTHS = { '6' => 'w-6', '8' => 'w-8', '10' => 'w-10', '12' => 'w-12', '14' => 'w-14', '16' => 'w-16' }.freeze

  def avatar_size_classes(height, width)
    "#{AVATAR_HEIGHTS.fetch(height.to_s, 'h-10')} #{AVATAR_WIDTHS.fetch(width.to_s, 'w-10')}"
  end

  def navigation_items
    links = [
      { body: 'Dashboard', href: user_path },
      { body: 'PowPals', href: users_path },
      { body: 'Mountains', href: root_path },
      { body: 'Passes', href: edit_profile_path }
    ]

    links << { body: 'My guest stays', href: guest_visits_path } if
      current_account&.user && GuestStay.exists?(guest: current_account.user)

    links.insert(1, { body: 'My houses', href: users_lodgings_path }) if current_account&.user&.house_access?
    links
  end

  def demo_database?
    Rails.env.development? && ApplicationRecord.connection_db_config.database == 'powpals_beta_demo_development'
  end

  def house_navigation(lodging)
    links = [['House overview', users_lodging_path(lodging)], ['Rooms', users_lodging_rooms_path(lodging)],
      ['Shared calendar', users_lodging_calendars_path(lodging)],
      ['My stays', my_calendar_users_lodging_calendars_path(lodging)]]
    links << ['Seasons & guest fees', users_lodging_house_seasons_path(lodging)] if policy(lodging).view_operations?
    links << ['Guest stays', users_lodging_guest_stays_path(lodging)] if policy(lodging).view_operations?
    links << ['Bed requests', users_lodging_bed_requests_path(lodging)] if policy(lodging).view_operations?
    links << ['Members', users_lodging_house_members_path(lodging)] if policy(lodging).view_operations?
    links << ['My payments', users_lodging_my_payments_path(lodging)]
    links
  end

  def can_plan_stay?(lodging, date)
    policy(lodging).stay? && (!lodging.season_start || date >= lodging.season_start) &&
      (!lodging.season_end || date <= lodging.season_end)
  end

  def navigation_class(path)
    if current_page?(path)
      'bg-gray-900 text-white rounded-md px-3 py-2 text-sm font-medium'
    else
      'text-gray-300 hover:bg-gray-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium'
    end
  end

  def navigation_aria(path)
    if current_page?(path)
      'page'
    else
      'false'
    end
  end
end
