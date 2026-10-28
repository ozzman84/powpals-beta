# frozen_string_literal: true

module Users
  class HouseSeasonsController < ApplicationController
    before_action :authenticate_account!
    before_action :load_house
    before_action :load_season, only: %i[show update quote]
    rescue_from ArgumentError, with: :invalid_input

    def index
      @seasons = @lodging.house_seasons.order(starts_on: :desc)
    end

    def show
      @entries = @season.house_ledger_entries.includes(:house_payments).order(:month_on, :id)
      @cells = @season.house_sheet_cells.order(:observed_on, :room_label, :id)
    end

    def create
      authorize @lodging, :update?
      season = @lodging.house_seasons.new(season_params)
      if season.save
        redirect_to users_lodging_house_season_path(@lodging, season)
      else
        redirect_to users_lodging_house_seasons_path(@lodging), alert: season.errors.full_messages.to_sentence
      end
    end

    def update
      authorize @lodging, :update?
      success = @season.update(season_params)
      redirect_to users_lodging_house_season_path(@lodging, @season),
        alert: (success ? nil : @season.errors.full_messages.to_sentence)
    end

    def quote
      values = params.expect(quote: [:arrival, :departure, :guests, :dogs]).to_h.symbolize_keys
      amount = GuestFeeQuote.new(@season).call(**values)
      redirect_to users_lodging_house_season_path(@lodging, @season),
        notice: "Guest-fee estimate: #{helpers.number_to_currency(amount / 100.0)}. No charge or payment was created."
    end

    private

    def load_house
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :view_operations?
    end

    def load_season
      @season = @lodging.house_seasons.find(params[:id])
    end

    def season_params
      values = params.expect(house_season: [:name, :starts_on, :ends_on, :rules, :policy_status,
        :monthly_rent, :participant_count, :dog_fee, :dog_fee_basis, :free_nights, { rates: Date::DAYNAMES }]).to_h
      convert_money(values)
    end

    def convert_money(values)
      { 'monthly_rent' => 'monthly_rent_cents', 'dog_fee' => 'dog_fee_cents' }.each do |input, field|
        next unless values.key?(input)

        value = values.delete(input)
        values[field] = value.present? ? HouseMoney.cents(value) : nil
      end

      if values.key?('rates')
        values['guest_rates'] = values.delete('rates').compact_blank
          .transform_values { |rate| HouseMoney.cents(rate) }
      end

      values
    end

    def invalid_input(error)
      redirect_to users_lodging_house_seasons_path(@lodging), alert: error.message
    end
  end
end
