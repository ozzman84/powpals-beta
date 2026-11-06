# frozen_string_literal: true

class GuestStayBilling
  def initialize(stay, accountant)
    @stay = stay
    @accountant = accountant
  end

  def post!
    @stay.with_lock do
      raise Pundit::NotAuthorizedError unless LodgingPolicy.new(@accountant, @stay.lodging).manage_finances?
      raise ArgumentError, 'Approve the guest stay before charging' unless @stay.approved?
      next @stay.house_ledger_entries if @stay.billed_at
      raise ActiveRecord::RecordInvalid, @stay unless @stay.valid?

      (@stay.arrival...@stay.departure).group_by(&:beginning_of_month).each do |month, nights|
        post_month(month, nights)
      end
      @stay.update!(billed_at: Time.current)
      @stay.house_ledger_entries.reload
    end
  end

  private

  def post_month(month, nights)
    season = @stay.house_season
    dogs = season.per_stay? && nights.first != @stay.arrival ? 0 : @stay.dogs
    amount = GuestFeeQuote.new(season).call(arrival: nights.first, departure: nights.last + 1, guests: 1, dogs: dogs)
    return if amount.zero?

    @stay.house_ledger_entries.create!(house_season: season, user: @stay.host, kind: :guest_fee,
      month_on: month, amount_cents: amount, description: "Guest stay: #{@stay.guest_name}",
      recorded_by: @accountant, source_key: "guest-stay-#{@stay.id}-#{month}",
      source_data: { arrival: nights.first, checkout: nights.last + 1, rates: season.guest_rates,
                     dogs: dogs, dog_fee_cents: season.dog_fee_cents, dog_fee_basis: season.dog_fee_basis })
  end
end
