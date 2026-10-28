# frozen_string_literal: true

class LodgingPolicy
  def initialize(account, lodging)
    @lodging = lodging
    @membership = lodging.roommates.find_by(user_id: account&.user&.id)
  end

  def show?
    @membership.present?
  end

  def update?
    @membership && %w[admin lease_holder].include?(@membership.role)
  end

  alias_method :destroy?, :update?
  alias_method :manage_roommates?, :update?
  alias_method :manage_rooms?, :update?

  def stay?
    show? && !@membership.guest? && !@lodging.archived?
  end
end
