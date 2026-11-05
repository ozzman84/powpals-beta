# frozen_string_literal: true

module Users
  class HouseMembersController < ApplicationController
    before_action :authenticate_account!
    before_action :load_directory

    def index
      @members = @season&.house_season_memberships&.includes(roommate: { user: :account }) || []
    end

    def create
      authorize @lodging, :manage_roommates?
      member = @lodging.roommates.find(params.require(:roommate_id))
      @season.house_season_memberships.find_or_create_by!(roommate: member)
      redirect_to users_lodging_house_members_path(@lodging, season_id: @season.id)
    end

    def update
      membership = @season.house_season_memberships.find(params[:id])
      manager = policy(@lodging).manage_roommates?
      raise Pundit::NotAuthorizedError unless manager || membership.roommate.user_id == current_account.user.id

      fields = if manager
                 [:status, :responsibilities, :pets, :pet_rules,
                   :preferences]
               else
                 [:pets, :preferences, :share_contact]
               end

      fields << :share_contact if membership.roommate.user_id == current_account.user.id
      values = params.expect(house_season_membership: fields)
      protect_manager!(membership) if values[:status] == 'former'
      membership.update!(values)
      redirect_to users_lodging_house_members_path(@lodging, season_id: @season.id)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to users_lodging_house_members_path(@lodging, season_id: @season.id),
        alert: e.record.errors.full_messages.to_sentence
    end

    private

    def protect_manager!(membership)
      return unless @season.starts_on == @lodging.season_start && @season.ends_on == @lodging.season_end
      return unless membership.roommate.user_id == current_account.user.id
      return if @lodging.roommates.accessible.where(role: %w[admin lease_holder])
        .where.not(id: membership.roommate_id).exists?

      membership.errors.add(:base, 'Keep at least one active house manager')
      raise ActiveRecord::RecordInvalid, membership
    end

    def load_directory
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :view_operations?
      @seasons = @lodging.house_seasons.order(starts_on: :desc)
      @season = if params[:season_id].present?
                  @seasons.find(params[:season_id])
                else
                  @seasons.find_by(starts_on: @lodging.season_start, ends_on: @lodging.season_end) || @seasons.first
                end

      raise ActiveRecord::RecordNotFound if action_name != 'index' && @season.nil?
    end
  end
end
