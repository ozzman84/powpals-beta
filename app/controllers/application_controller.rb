# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError do
    head :forbidden
  end

  private

  def pundit_user
    current_account
  end
end
