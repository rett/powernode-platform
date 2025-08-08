# frozen_string_literal: true

class Api::V1::RegistrationsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  # POST /api/v1/registrations
  def create
    ActiveRecord::Base.transaction do
      @account = Account.new(account_params)
      @account.save!

      @user = @account.users.build(user_params)
      @user.save!

      # Assign Owner role to the first user (handled automatically in User model)
      owner_role = Role.find_by(name: 'Owner')
      @user.assign_role(owner_role) if owner_role

      tokens = JwtService.generate_tokens(@user)
      @user.record_login!

      render json: {
        user: user_data(@user),
        account: account_data(@account),
        tokens: tokens,
        message: 'Account created successfully'
      }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: {
      error: 'Registration failed',
      details: e.record.errors.full_messages
    }, status: :unprocessable_entity
  rescue StandardError => e
    render json: {
      error: 'Registration failed',
      message: e.message
    }, status: :unprocessable_entity
  end

  private

  def account_params
    params.require(:registration).permit(:account_name, :subdomain)
          .transform_keys { |key| key == 'account_name' ? 'name' : key }
  end

  def user_params
    params.require(:registration).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def user_data(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      role: user.role,
      status: user.status,
      email_verified: user.email_verified?
    }
  end

  def account_data(account)
    {
      id: account.id,
      name: account.name,
      subdomain: account.subdomain,
      status: account.status
    }
  end
end