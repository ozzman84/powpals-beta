# frozen_string_literal: true

class LodgingPolicy
  def initialize(account, lodging)
    @lodging = lodging
    @membership = lodging.roommates.accessible.find_by(user_id: account&.user&.id)
  end

  def show?
    @membership.present?
  end

  def view_operations?
    show? && !@membership.guest?
  end

  def manage_finances?
    @membership&.accountant? || false
  end

  def collect_rent?
    @membership&.rent_collector? || false
  end

  def my_payments?
    show?
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
