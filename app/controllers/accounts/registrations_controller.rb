# frozen_string_literal: true

module Accounts
  class RegistrationsController < Devise::RegistrationsController
    # Devise implements the create action in the superclass.
    before_action :configure_sign_up_params, only: [:create] # rubocop:disable Rails/LexicallyScopedActionFilter

    protected

    def build_resource(attributes = {})
      super
      resource.build_user unless resource.user
    end

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [
        :email, :password, :password_confirmation,
        { user_attributes: %i[first_name last_name level ride_type city state] }
      ])
    end

    def after_sign_up_path_for(_resource)
      user_path
    end

    def after_inactive_sign_up_path_for(_resource)
      new_account_session_path
    end
  end
end
